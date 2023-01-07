# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential Repo information for API output
module UFeeling
  module Representer
    # Represent a Video entity as Json
    class SentimentInfo < Roar::Decorator
      include Roar::JSON

      property :sentiment_id
      property :sentiment_name
      property :sentiment_score
    end
  end
end
