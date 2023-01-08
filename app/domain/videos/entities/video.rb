# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative '../values/publish_info'

module UFeeling
  module Videos
    module Entity
      # Provides access to Category data
      class Video < Dry::Struct
        include Dry.Types

        attribute :id,                      Integer.optional
        attribute :author_id,               Integer.optional
        attribute :category_id,             Integer.optional
        attribute :origin_id,               Strict::String
        attribute :origin_category_id,      Strict::String
        attribute :origin_author_id,        Strict::String
        attribute :published_info,          UFeeling::Videos::Values::PublishedInfo
        attribute :sentiment,               UFeeling::Videos::Values::SentimentalScore.optional
        attribute :title,                   Strict::String
        attribute :description,             Strict::String
        attribute :thumbnail_url,           String.optional
        attribute :status,                  String.default('New')
        attribute :comment_count,           Integer.optional
        attribute :duration,                String.optional
        attribute :tags,                    String.optional
        attribute :author,                  Author.optional

        def to_attr_hash
          to_hash.except(:id, :author, :published_info, :sentiment)
            .merge(published_info.to_attr_hash)
            .merge(sentiment.to_attr_hash)
        end

        def processing?
          status == 'processing'
        end

        def completed?
          status == 'completed'
        end
      end
    end
  end
end
