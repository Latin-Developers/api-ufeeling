# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'sentiment_representer'

module UFeeling
  module Representer
    # Represents list of videos for API output
    class SentimentsList < Roar::Decorator
      include Roar::JSON

      collection :sentiments, extend: Representer::Sentiment,
                              class: Representer::OpenStructWithLinks
    end
  end
end
