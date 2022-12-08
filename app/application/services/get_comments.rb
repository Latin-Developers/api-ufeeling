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
        comments = Videos::Repository::For.klass(Videos::Entity::Comment)
          .find_video_comments(input[:video_id])
          puts(comments)
        
        if comments
          Success(Response::ApiResult.new(status: :ok, message: comments))
        else
          Failure(Response::ApiResult.new(status: :not_found, message: "Comments #{input[:video_id]} not found"))
        end

      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end
    end
  end
end
