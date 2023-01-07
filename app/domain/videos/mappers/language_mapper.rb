# frozen_string_literal: false

require 'cld'
require 'concurrent'
require 'vader_sentiment_ruby'
require 'aws-sdk-comprehend'
require 'yaml'

module UFeeling
  module Videos
    module Mappers
      # Data Mapper: Youtube Video Comments - Language Analysis
      class AWSLanguage
        def initialize(aws_region, access_key_id, secret_access_key, gateway_class = AWS::SDK)
          @aws_region = aws_region
          @access_key_id = access_key_id
          @secret_access_key = secret_access_key
          @gateway = gateway_class.new(@aws_region, @access_key_id, @secret_access_key)
        end

        def language(text)
          language_data = @gateway.detect_language(text)
          AWSLanguage.build_entity(language_data)
        rescue StandardError => e
          puts "Error Evaluating Language: #{e}"
          UFeeling::Videos::Values::Language.new(
            language_code: 'en',
            language_confidence: 0.0,
            language_name: 'English'
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
            UFeeling::Videos::Values::Language.new(
              language_code:,
              language_confidence:,
              language_name:
            )
          end

          private

          def language_code
            @data[0][0].values[0]
          end

          def language_confidence
            @data[0][0].values[1]
          end

          def language_name
            languages = YAML.safe_load_file('./language_names.yml')
            languages.find { |l| l['code'] == language_code }['language']
          rescue StandardError => e
            puts "Error Evaluating Language: #{e}"
          end
        end
      end
    end
  end
end
