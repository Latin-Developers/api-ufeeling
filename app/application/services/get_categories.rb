# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class GetCategories
      include Dry::Transaction

      step :get_categories

      private

      DB_ERR_MSG = 'Having trouble accessing the database'

      # Get categories

      def get_categories(input)
        input[:categories] = Videos::Repository::For.klass(Videos::Entity::Category)
          .find_video_categories(input[:video][:id])

        Success(input)
      rescue StandardError
        Failure('Could not get categories')
      end
    end
  end
end