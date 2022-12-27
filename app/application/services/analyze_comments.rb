# frozen_string_literal: true

require 'dry/monads'
require 'dry/transaction'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class AnalyzeComments
      include Dry::Transaction

      step :get_comments_from_youtube
      step :save_comments_in_db
      step :update_video_status

      private

      COMMENTS_DB_ERR_MSG = 'Having trouble saving comments in the database'
      YT_COMMENTS_ERROR = 'Having trouble getting comments from youtube'
      VIDEO_DB_ERR_MSG = 'Having trouble updating video in the database'

      def get_comments_from_youtube(input)
        input[:comments] = UFeeling::Videos::Mappers::ApiComment
          .new(UFeeling::App.config.YOUTUBE_API_KEY)
          .comments(input[:video_id], input[:lambda])
        Success(input)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: YT_COMMENTS_ERROR))
      end

      def save_comments_in_db(input)
        UFeeling::Videos::Repository::For
          .klass(UFeeling::Videos::Entity::Comment)
          .find_or_create_many(input[:comments], input[:lambda])
        Success(input)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: COMMENTS_DB_ERR_MSG))
      end

      def update_video_status(input)
        video = video_in_database(input)
        video = UFeeling::Videos::Entity::Video.new(video.to_h.merge(status: 'completed'))

        UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Video)
          .update(video)

        Success(Response::ApiResult.new(status: :ok, message: video))
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: VIDEO_DB_ERR_MSG))
      end

      def video_in_database(input)
        Videos::Repository::For.klass(Videos::Entity::Video)
          .find_by_origin_id(input[:video_id])
      end
    end
  end
end
