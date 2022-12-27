# frozen_string_literal: true

require_relative 'progress_publisher'

# Shoryuken module to handle get the comments in parallel
module GetComments
  # Reports job progress to client
  class JobReporter
    attr_accessor :project

    def initialize(request_json, config)
      video_request = UFeeling::Representer::Video
        .new(OpenStruct.new) # rubocop:disable Style/OpenStructUse
        .from_json(request_json)

      @project = video_request.project
      @publisher = ProgressPublisher.new(config, video_request.origin_id)
    end

    def report(msg)
      @publisher.publish msg
    end

    def report_each_second(seconds, &operation)
      seconds.times do
        sleep(1)
        report(operation.call)
      end
    end
  end
end
