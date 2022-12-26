# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Transaction to store a video with comments from Youtube API to database
    class FindOrCreateAuthor
      include Dry::Transaction

      step :validate_author_in_db
      step :store_author_in_db

      private

      DB_ERR_MSG = 'Having trouble saving the video author in the database'
      YT_NOT_FOUND_MSG = 'Could not find the video author in youtube'

      # Get author from Youtube
      def validate_author_in_db(input)
        if (author = author_from_db(input))
          input[:local_author] = author
        else
          input[:remote_author] = author_from_origin(input)
        end
        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def store_author_in_db(input)
        # Add author to database
        author = if (new_author = input[:remote_author])
                   Database::AuthorOrm.find_or_create(new_author.to_attr_hash)
                 else
                   input[:local_author]
                 end
        Success(Response::ApiResult.new(status: :created, message: author))
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Support methods that other services could use
      def author_from_origin(input)
        UFeeling::Videos::Mappers::ApiAuthor.new(App.config.YOUTUBE_API_KEY)
          .author(input[:origin_id])
      rescue StandardError
        raise YT_NOT_FOUND_MSG
      end

      def author_from_db(input)
        Videos::Repository::For.klass(Videos::Entity::Author)
          .find_by_origin_id(input[:origin_id])
      end

      def print_error(error)
        App.logger.error [error.inspect, error.backtrace].flatten.join("\n")
      end
    end
  end
end
