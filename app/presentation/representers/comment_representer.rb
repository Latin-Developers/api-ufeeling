# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'sentiment_representer'
require_relative 'author_representer'
require_relative 'language_representer'
require_relative 'published_info_representer'

# Represents essential Repo information for API output
module UFeeling
  module Representer
    # Represent a Video entity as Json
    class Comment < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :origin_id
      property :text_original
      property :total_reply_count
      property :sentiment, extend: Representer::SentimentRepresenter, class: OpenStruct # rubocop:disable Style/OpenStructUse
      property :published_info, extend: Representer::PublishedInfoRepresenter, class: OpenStruct # rubocop:disable Style/OpenStructUse
      property :author, extend: Representer::AuthorRepresenter, class: OpenStruct # rubocop:disable Style/OpenStructUse
      property :language, extend: Representer::LanguageRepresenter, class: OpenStruct # rubocop:disable Style/OpenStructUse

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
