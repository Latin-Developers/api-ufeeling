# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative '../values/publish_info'
require_relative '../values/sentimental_score'

module UFeeling
  module Videos
    module Entity
      # Provides access to comment data
      class Comment < Dry::Struct
        include Dry.Types

        attribute :id,                        Integer.optional
        attribute :video_id,                  Integer.optional
        attribute :author_channel_id,         Integer.optional
        attribute :origin_id,                 Strict::String
        attribute :video_origin_id,           Strict::String
        attribute :author_channel_origin_id,  Strict::String
        attribute :text_display,              Strict::String
        attribute :text_original,             Strict::String
        attribute :like_count,                Strict::Integer
        attribute :total_reply_count,         Strict::Integer
        attribute :published_info,            UFeeling::Videos::Values::PublishedInfo
        attribute :sentiment,                 UFeeling::Videos::Values::SentimentalScore

        # TODO: Move into a CommentReplies class
        attribute :comment_replies,           Array.of(Comment)

        def to_attr_hash
          to_hash.except(:id, :published_info, :comment_replies, :sentiment)
            .merge(published_info.to_attr_hash)
            .merge(sentiment.to_attr_hash)
        end

        def confidence
          sentiment.sentiment_score
        end

        def sentiment_name
          sentiment.sentiment_name
        end
      end
    end
  end
end
