# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Transaction to store a video with comments from Youtube API to database
    class AnalyzeVideo
      include Dry::Transaction

      step :get_video
      step :get_comments
      step :add_comments_to_db

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
      def get_comments(input)
        return Success(input) if input[:video].proccessed

        Messaging::Queue.new(App.config.VIDEO_QUEUE_URL, App.config)
          .send(Representer::Video.new(input[:video]).to_json)

        Failure(Response::ApiResult.new(status: :processing, message: PROCESSING_MSG))
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: YT_COMMENTS_ERROR))
      end

      # Add comments to database
      def add_comments_to_db(input)
        Videos::Repository::For
          .klass(Videos::Entity::Comment)
          .find_or_create_many(input[:comments])

        Success(Response::ApiResult.new(status: :ok, message: input[:video]))
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def comment_in_database(input)
        Videos::Repository::For.klass(Videos::Entity::Video)
          .find_by_origin_id(input[:video_id])
      end

      def print_error(error)
        App.logger.error [error.inspect, error.backtrace].flatten.join("\n")
      end
    end
  end
end
