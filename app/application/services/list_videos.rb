# frozen_string_literal: true

require 'dry/monads'
require 'dry/transaction'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class ListVideos
      include Dry::Transaction

      step :validate_filters
      step :retrieve_videos

      private

      DB_ERR = 'Cannot access database'

      # Expects list of movies in input[:list_request]
      def validate_filters(input)
        filters = input[:filters].call
        if filters.success?
          filters_value = filters.value!
          Success(input.merge(video_ids: filters_value[:video_ids], categories: filters_value[:categories]))
        else
          Failure(filters.failure)
        end
      end

      def retrieve_videos(input)
        Videos::Repository::For.klass(Videos::Entity::Video).find(input[:video_ids], input[:categories])
          .then { |videos| Response::VideosList.new(videos) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      rescue StandardError
        Failure(
          Response::ApiResult.new(status: :internal_error, message: DB_ERR)
        )
      end
    end
  end
end
