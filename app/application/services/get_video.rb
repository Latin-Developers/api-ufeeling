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

      def get_video(input)
        video = Videos::Repository::For.klass(Videos::Entity::Video)
          .find_by_origin_id(input[:video_id])

        if video
          Success(Response::ApiResult.new(status: :ok, message: video))
        else
          Failure(Response::ApiResult.new(status: :not_found, message: "Video #{input[:video_id]} not found"))
        end
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
