# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class GetSentiments
      include Dry::Transaction

      step :obtain_sentiments

      private

      DB_ERR_MSG = 'Having trouble accessing the database'

      # Get sentiments
      def obtain_sentiments
        Videos::Repository::For.klass(Videos::Entity::Sentiment)
          .all
          .then { |sentiments| Response::SentimentsList.new(sentiments) }
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
