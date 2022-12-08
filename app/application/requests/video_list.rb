# frozen_string_literal: true

require 'base64'
require 'dry/monads'
require 'json'

module UFeeling
  module Request
    # Video list request parser
    class EncodedVideoList
      include Dry::Monads::Result::Mixin

      def initialize(params)
        @params = params
      end

      # Use in API to parse incoming list requests
      def call
        video_ids = JSON.parse(decode(@params['video_ids']) || '[]')
        categories = JSON.parse(decode(@params['categories']) || '[]')
        Success(video_ids:, categories:)
      rescue StandardError
        Failure(
          Response::ApiResult.new(
            status: :bad_request,
            message: 'Video list not found'
          )
        )
      end

      # Decode params
      def decode(param)
        param ? Base64.urlsafe_decode64(param) : nil
      end

      # Client App will encode params to send as a string
      # - Use this method to create encoded params for testing
      def self.to_encoded(data)
        Base64.urlsafe_encode64(data.to_json)
      end

      # Use in tests to create a VideoList object from a list
      def self.to_request(video_ids, categories)
        EncodedVideoList.new('video_ids' => to_encoded(video_ids), 'categories' => to_encoded(categories))
      end
    end
  end
end
