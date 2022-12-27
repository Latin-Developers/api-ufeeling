# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Transaction to store a video with comments from Youtube API to database
    class AnalyzeVideo
      include Dry::Transaction

      step :get_video
      step :validate_comments_proccessed

      private

      DB_ERR_MSG = 'Having trouble accessing the database'
      YT_NOT_FOUND_MSG = 'Could not find video in youtube'
      YT_COMMENTS_ERROR = 'Having trouble getting comments from youtube'
      PROCESSING_MSG = 'Processing the summary request'

      # Get video from Youtube
      def get_video(input)
        input[:video] = Videos::Repository::For.klass(Videos::Entity::Video)
          .find_by_origin_id(input[:video_id])

        if input[:video]
          Success(input)
        else
          Failure(Response::ApiResult.new(status: :not_found, message: "Video #{input[:video_id]} not found"))
        end
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Get comments from Youtube
      def validate_comments_proccessed(input)
        return Success(Response::ApiResult.new(status: :ok, message: input[:video])) if input[:video].completed?
        return Failure(processing_result(input)) if input[:video].processing?

        start_queue(input)

        Failure(processing_result(input))
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: YT_COMMENTS_ERROR))
      end

      def start_queue(input)
        video_hash = input[:video].to_h.merge(status: 'processing')
        video = Videos::Entity::Video.new(video_hash)
        Videos::Repository::For.klass(Videos::Entity::Video).update(video)

        Messaging::Queue.new(App.config.VIDEO_QUEUE_URL, App.config)
          .send(video_representer(input).to_json)
      end

      def processing_result(input)
        Response::ApiResult.new(
          status: :processing,
          message: { video_id: input[:video_id], msg: PROCESSING_MSG }
        )
      end

      def print_error(error)
        App.logger.error [error.inspect, error.backtrace].flatten.join("\n")
      end

      def video_representer(input)
        Representer::Video.new(input[:video])
      end
    end
  end
end
