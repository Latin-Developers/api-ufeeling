# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class GetComments
      include Dry::Transaction

      step :get_comments

      private

      DB_ERR_MSG = 'Having trouble accessing the database'

      # Get comments

      def get_comments(input)
        Videos::Repository::For.klass(Videos::Entity::Comment)
          .find_video_comments(input[:video_id])
          .then { |comments| Response::CommentsList.new(comments) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end
    end
  end
end
