# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential Repo information for API output
module UFeeling
  module Representer
    # Represent a Video entity as Json
    class LanguageRepresenter < Roar::Decorator
      include Roar::JSON

      property :language_name
      property :language_code
      property :language_reliable
    end
  end
end
