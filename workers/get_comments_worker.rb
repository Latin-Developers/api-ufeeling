# frozen_string_literal: true

require_relative '../require_app'
require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to get the comments in parallel
class GetCommentsWorker
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
  shoryuken_options queue: config.VIDEO_QUEUE_URL, auto_delete: true

  def perform(_sqs_msg, request)
    video = UFeeling::Representer::Video
      .new(OpenStruct.new).from_json(request) # rubocop:disable Style/OpenStructUse

    comments = UFeeling::Videos::Mappers::ApiComment
      .new(UFeeling::App.config.YOUTUBE_API_KEY)
      .comments(video.origin_id)

    # TODO: Move into a API Call
    UFeeling::Videos::Repository::For
      .klass(UFeeling::Videos::Entity::Comment)
      .find_or_create_many(comments)
  rescue StandardError => e
    puts "Error executing worker: #{e}"
  end
end
