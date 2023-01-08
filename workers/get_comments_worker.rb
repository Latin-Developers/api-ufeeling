# frozen_string_literal: true

require_relative '../require_app'
require_relative 'get_comments_monitor'
require_relative 'job_reporter'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken module to handle get the comments in parallel
module GetComments
  # Shoryuken worker class to get the comments in parallel
  class Worker
    # Environment variables setup
    Figaro.application = Figaro::Application.new(
      environment: ENV['RACK_ENV'] || 'development',
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    def self.config = Figaro.env

    Shoryuken.sqs_client = Aws::SQS::Client.new(
      access_key_id: config.AWS_ACCESS_KEY_ID,
      secret_access_key: config.AWS_SECRET_ACCESS_KEY,
      region: config.AWS_REGION
    )

    include Shoryuken::Worker
    Shoryuken.sqs_client_receive_message_opts = { wait_time_seconds: 20 }
    shoryuken_options queue: config.VIDEO_QUEUE_URL, auto_delete: true, concurrency: 1

    def perform(_sqs_msg, request)
      video = UFeeling::Representer::Video.new(OpenStruct.new).from_json(request) # rubocop:disable Style/OpenStructUse

      job = JobReporter.new(request, Worker.config)
      job.report_each_second(5) { GetCommentsMonitor.starting_percent }
      update_lamda = update_lamda(job, video.comment_count)

      UFeeling::Services::AnalyzeComments.new.call(video_id: video.origin_id, lambda: update_lamda)

      job.report_each_second(5) { GetCommentsMonitor.finished_percent }
    rescue StandardError => e
      puts "Error executing worker: #{e}"
    end

    def update_lamda(job, total_comments)
      lambda { |step, comments_processed|
        job.report GetCommentsMonitor.progress(step, comments_processed, total_comments)
      }
    end
  end
end
