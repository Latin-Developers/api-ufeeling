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
        input[:comments] = Videos::Repository::For.klass(Videos::Entity::Comment)
          .find_video_comments(input[:video][:id])

        Success(input)
      rescue StandardError
        Failure('Could not get video comments')
      end
    end
  end
end
