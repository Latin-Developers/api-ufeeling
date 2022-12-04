# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential Repo information for API output
module UFeeling
  module Representer
    # Represent a Video entity as Json
    class Comment < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :origin_id
      property :text_display
      property :total_reply_count
      property :sentiment_score
      property :published_at

      link :self do
        "#{App.config.API_HOST}/api/v1/videos/#{video_origin_id}/comments"
      end

      private

      def video_origin_id
        represented.origin_id
      end
    end
  end
end
