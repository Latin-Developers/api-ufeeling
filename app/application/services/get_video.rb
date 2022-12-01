# frozen_string_literal: true

require 'dry/transaction'

# TODO: Move get comments to it's own service
module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class GetVideo
      include Dry::Transaction

      step :get_video
      step :get_comments

      private

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
