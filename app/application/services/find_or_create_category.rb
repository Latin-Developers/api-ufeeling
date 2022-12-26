# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Transaction to store a video category from Youtube API to database
    class FindOrCreateCategory
      include Dry::Transaction

      step :validate_category_in_db
      step :store_category_in_db

      private

      DB_ERR_MSG = 'Having trouble saving the video category in the database'
      YT_NOT_FOUND_MSG = 'Could not find the video category in youtube'

      # Get category from Youtube
      def validate_category_in_db(input)
        if (category = category_from_db(input))
          input[:local_category] = category
        else
          input[:remote_category] = category_from_origin(input)
        end
        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def store_category_in_db(input)
        # Add category to database
        category = if (new_category = input[:remote_category])
                     Database::CategoryOrm.find_or_create(new_category.to_attr_hash)
                   else
                     input[:local_category]
                   end
        Success(Response::ApiResult.new(status: :created, message: category))
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Support methods that other services could use
      def category_from_origin(input)
        UFeeling::Videos::Mappers::ApiCategory.new(App.config.YOUTUBE_API_KEY)
          .category(input[:origin_id])
      rescue StandardError
        raise YT_NOT_FOUND_MSG
      end

      def category_from_db(input)
        Videos::Repository::For.klass(Videos::Entity::Category)
          .find_by_origin_id(input[:origin_id])
      end

      def print_error(error)
        App.logger.error [error.inspect, error.backtrace].flatten.join("\n")
      end
    end
  end
end
