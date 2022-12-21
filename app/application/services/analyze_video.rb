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
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Get comments from Youtube
      def get_comments(input)
        # Add this line after worker
        # return Success(input) if input[:video].comments_proccessed

        input[:comments] = Videos::Mappers::ApiComment
          .new(App.config.YOUTUBE_API_KEY)
          .comments(input[:video].origin_id)

        Success(input)
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: YT_COMMENTS_ERROR))
      end

      # Add comments to database
      def add_comments_to_db(input)
        Videos::Repository::For
          .klass(Videos::Entity::Comment)
          .find_or_create_many(input[:comments])

        Success(Response::ApiResult.new(status: :ok, message: input[:video]))
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def comment_in_database(input)
        Videos::Repository::For.klass(Videos::Entity::Video)
          .find_by_origin_id(input[:video_id])
      end
    end
  end
end
