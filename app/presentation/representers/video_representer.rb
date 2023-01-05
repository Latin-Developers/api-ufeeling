# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential Repo information for API output
module UFeeling
  module Representer
    # Represent a Video entity as Json
    class Video < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :origin_id
      property :title
      property :description
      property :thumbnail_url
      property :comment_count
      property :author, extend: Representer::AuthorRepresenter, class: OpenStruct # rubocop:disable Style/OpenStructUse

      link :self do
        "#{App.config.API_HOST}/api/v1/videos/#{video_origin_id}"
      end

      private

      def video_origin_id
        represented.origin_id
      end
    end
  end
end
