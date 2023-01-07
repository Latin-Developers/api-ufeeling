# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class GetComments
      include Dry::Transaction

      step :validate_filters
      step :get_comments

      private

      DB_ERR_MSG = 'Having trouble accessing the database'

      # Expects list of movies in input[:list_request]
      def validate_filters(input)
        filters = input[:filters].call
        if filters.success?
          filters_value = filters.value!
          Success(input.merge(sentiment_id: filters_value[:sentiment_id]))
        else
          Failure(filters.failure)
        end
      end

      # Get comments
      def get_comments(input)
        Videos::Repository::For.klass(Videos::Entity::Comment)
          .find_video_comments(input[:video_id], input[:sentiment_id])
          .then { |comments| Response::CommentsList.new(comments) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def print_error(error)
        App.logger.error [error.inspect, error.backtrace].flatten.join("\n")
      end
    end
  end
end
