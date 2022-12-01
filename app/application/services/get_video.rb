# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class GetVideo
      include Dry::Transaction

      step :get_video

      private

      DB_ERR_MSG = 'Having trouble accessing the database'

      # Get video

      def get_video(video_id)
        video = Videos::Repository::For.klass(Videos::Entity::Video)
          .find(video_id)

        if video
          Success(video:)
        else
          Failure("Video #{video_id} not found")
        end
      rescue StandardError
        Failure('Could not obtain video')
      end
    end
  end
end
