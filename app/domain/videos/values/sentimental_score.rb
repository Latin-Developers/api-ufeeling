# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module UFeeling
  module Videos
    module Values
      # Publish infos
      class SentimentalScore < Dry::Struct
        include Dry.Types

        attribute :sentiment_id,          Coercible::Integer.optional
        attribute :sentiment_name,        Strict::String.optional
        attribute :sentiment_score,       Strict::Float.optional

        def to_attr_hash
          to_hash.except(:sentiment_name)
        end
      end
    end
  end
end
