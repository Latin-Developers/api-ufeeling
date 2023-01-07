# frozen_string_literal: false

require 'cld'
require 'concurrent'
require 'vader_sentiment_ruby'
require 'aws-sdk-comprehend'

module UFeeling
  module Videos
    module Mappers
      # Data Mapper: Youtube Video -> Entity Video
      class AWSSentiment
        def initialize(aws_region, access_key_id, secret_access_key, gateway_class = AWS::SDK)
          @aws_region = aws_region
          @access_key_id = access_key_id
          @secret_access_key = secret_access_key
          @gateway = gateway_class.new(@aws_region, @access_key_id, @secret_access_key)
        end

        def sentiment(text, language_code)
          sentiment_data = @gateway.detect_sentiment(text, language_code)
          AWSSentiment.build_entity(sentiment_data)
        rescue StandardError
          UFeeling::Videos::Values::SentimentalScore.new(
            sentiment_id: nil,
            sentiment_name: 'neutral',
            sentiment_score: 0.0
          )
        end

        def self.build_entity(data)
          DataMapper.new(data).build_entity
        end

        # Extracts entity specific elements from data structure
        class DataMapper
          def initialize(data)
            @data = data
          end

          def build_entity
            UFeeling::Videos::Values::SentimentalScore.new(
              sentiment_id: nil,
              sentiment_name:,
              sentiment_score:
            )
          end

          private

          def sentiment_name
            @data.sentiment.to_s.downcase
          end

          def sentiment_score
            @data.sentiment_score.max_by { |_k, v| v }
          end
        end
      end
    end
  end
end
