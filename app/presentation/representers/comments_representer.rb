# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'comment_representer'

module UFeeling
  module Representer
    # Represents list of projects for API output
    class CommentsList < Roar::Decorator
      include Roar::JSON

      collection :comments, extend: Representer::Comment,
                            class: Representer::OpenStructWithLinks
    end
  end
end