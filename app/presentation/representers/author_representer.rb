# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential Repo information for API output
module UFeeling
  module Representer
    # Represent a Video entity as Json
    class AuthorRepresenter < Roar::Decorator
      include Roar::JSON

      property :id
      property :origin_id
      property :name
      property :thumbnail_url
    end
  end
end
