# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module UFeeling
  module Videos
    module Values
      # Comment Language Values
      class Language < Dry::Struct
        include Dry.Types

        attribute :language_name,           Strict::String
        attribute :language_code,           Strict::String
        attribute :language_confidence,     Strict::Float

        def to_attr_hash
          to_hash
        end
      end
    end
  end
end
