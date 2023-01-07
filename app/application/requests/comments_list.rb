# frozen_string_literal: true

require 'base64'
require 'dry/monads'
require 'json'

module UFeeling
  module Request
    # Comment list request parser
    class EncodedCommentList
      include Dry::Monads::Result::Mixin

      def initialize(params)
        @params = params
      end

      # Use in API to parse incoming list requests
      def call
        sentiment_id = JSON.parse(decode(@params['sentiment_id']) || '[]')
        Success(sentiment_id:)
      rescue StandardError
        Failure(
          Response::ApiResult.new(
            status: :bad_request,
            message: 'Comment list not found'
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

      # Use in tests to create a CommentList object from a list
      def self.to_request(sentiment_id)
        EncodedCommentList.new('sentiment_id' => to_encoded(sentiment_id))
      end
    end
  end
end
