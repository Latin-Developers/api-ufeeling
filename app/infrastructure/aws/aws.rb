# frozen_string_literal: true

module UFeeling
  module AWS
    # Library for Youtube Web API
    class SDK
      def initialize(aws_region, access_key_id, secret_access_key)
        @aws_region = aws_region
        @access_key_id = access_key_id
        @secret_access_key = secret_access_key
      end

      def detect_sentiment(text, language_code)
        client.detect_sentiment({
                                  text:,
                                  language_code:
                                })
      end

      private

      def client
        Aws::Comprehend::Client.new(
          region: @aws_region,
          access_key_id: @access_key_id,
          secret_access_key: @secret_access_key
        )
      end
    end
  end
end
