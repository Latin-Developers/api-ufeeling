# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'category_representer'

module UFeeling
  module Representer
    # Represents list of videos for API output
    class CategoriesList < Roar::Decorator
      include Roar::JSON

      collection :categories, extend: Representer::Category,
                              class: Representer::OpenStructWithLinks
    end
  end
end
