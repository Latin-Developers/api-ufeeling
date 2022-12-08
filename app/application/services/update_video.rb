# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Transactions to update the data related to a Video and it comment, from Youtube API to database.
    class UpdateVideo
      include Dry::Transaction

      step :get_video
      step :update_video_in_db
      step :get_comments
      step :update_comments_in_db

      private

      DB_ERR_MSG = 'Having trouble accessing the database'
      YT_NOT_FOUND_MSG = 'Could not find video in youtube'
      YT_COMMENTS_ERROR = 'Having trouble getting comments from youtube'

      # Get video from Youtube and validate if it exist in the database
      def get_video(input)
        if (video = video_in_database(input))
          input[:local_video] = video
          input[:remote_video] = video_from_origin(input)
          Success(input)
        else
          Failure(Response::ApiResult.new(status: :not_found,
                                          message: "Video #{input[:local_video]} does not exits in the Database"))
        end
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def update_video_in_db(input)
        # Update local video in database if there is any new data
        video = Videos::Repository::For.klass(Videos::Entity::Video).update(input[:remote_video])

        Success(video:)
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Get comments from Youtube
      def get_comments(input)
        input[:comments] = Videos::Mappers::ApiComment
          .new(App.config.YOUTUBE_API_KEY)
          .comments(input[:video][:origin_id])

        Success(input)
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: YT_COMMENTS_ERROR))
      end

      # Update comments to database
      def update_comments_in_db(input)
        input[:comments].each do |comment|
          Videos::Repository::For
            .klass(Videos::Entity::Comment)
            .update_or_create(comment)
        end
        Success(Response::ApiResult.new(status: :created, message: input[:video]))
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Support methods that other services could use

      def video_from_origin(input)
        Videos::Mappers::ApiVideo
          .new(App.config.YOUTUBE_API_KEY).details(input[:video_id])
      rescue StandardError
        raise YT_NOT_FOUND_MSG
      end

      def video_in_database(input)
        Videos::Repository::For.klass(Videos::Entity::Video)
          .find_by_origin_id(input[:video_id])
      end
    end
  end
end
