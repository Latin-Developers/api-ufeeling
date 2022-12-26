# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Transactions to update the data related to a Video and it comment, from Youtube API to database.
    class UpdateVideo
      include Dry::Transaction

      step :get_video
      step :find_video_category
      step :fill_video_author
      step :update_video_in_db

      private

      CATEGORY_ERR_MSG = 'Having trouble getting video category'
      AUTHOR_ERR_MSG = 'Having trouble getting video author'
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

      # Gets or creates video category
      def find_video_category(input)
        origin_id = input[:remote_video].origin_category_id
        category_result = Services::FindOrCreateCategory.new.call(origin_id:)
        input[:category] = category_result.value!.message

        Success(input)
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: CATEGORY_ERR_MSG))
      end

      # Gets or creates video author
      def fill_video_author(input)
        origin_id = input[:remote_video].origin_author_id
        author_result = Services::FindOrCreateAuthor.new.call(origin_id:)
        input[:author] = author_result.value!.message
        Success(input)
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: AUTHOR_ERR_MSG))
      end

      # Updates video information in the database
      def update_video_in_db(input)
        # Update local video in database if there is any new data
        video_updated = fill_foreign_keys(input[:remote_video], input[:category], input[:author])
        Videos::Repository::For.klass(Videos::Entity::Video).update(video_updated)
        Services::AnalyzeVideo.new.call(video_id: input[:video_id])
      rescue StandardError => e
        print_error(e)
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

      def print_error(error)
        App.logger.error [error.inspect, error.backtrace].flatten.join("\n")
      end

      def fill_foreign_keys(video, category, author)
        remote_video_hash = video.to_h.merge(category_id: category.id,
                                             author_id: author.id,
                                             status: 'processing')
        Videos::Entity::Video.new(remote_video_hash)
      end
    end
  end
end
