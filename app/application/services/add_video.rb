# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Transaction to store a video with comments from Youtube API to database
    class AddVideo
      include Dry::Transaction

      step :get_video
      step :find_video_category
      step :fill_video_author
      step :add_video_to_db

      private

      CATEGORY_ERR_MSG = 'Having trouble getting video category'
      AUTHOR_ERR_MSG = 'Having trouble getting video author'
      DB_ERR_MSG = 'Having trouble accessing the database'
      YT_NOT_FOUND_MSG = 'Could not find video in youtube'

      # Get video from Youtube
      def get_video(input)
        if (video = video_in_database(input))
          input[:local_video] = video
        else
          input[:remote_video] = video_from_origin(input)
        end
        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def find_video_category(input)
        if input[:remote_video]
          origin_id = input[:remote_video].origin_category_id
          category_result = Services::FindOrCreateCategory.new.call(origin_id:)
          input[:category] = category_result.value!.message
        end

        Success(input)
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: CATEGORY_ERR_MSG))
      end

      def fill_video_author(input)
        if input[:remote_video]
          origin_id = input[:remote_video].origin_author_id
          author_result = Services::FindOrCreateAuthor.new.call(origin_id:)
          input[:author] = author_result.value!.message
        end
        Success(input)
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: AUTHOR_ERR_MSG))
      end

      def add_video_to_db(input)
        # Add video to database
        video = if (new_video = input[:remote_video])
                  new_video = fill_foreign_keys(new_video, input[:category], input[:author])
                  Videos::Repository::For.klass(Videos::Entity::Video).find_or_create(new_video)
                  video_in_database(input)
                else
                  input[:local_video]
                end
        Success(Response::ApiResult.new(status: :created, message: video))
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
                                             author_id: author.id)
        Videos::Entity::Video.new(remote_video_hash)
      end
    end
  end
end
