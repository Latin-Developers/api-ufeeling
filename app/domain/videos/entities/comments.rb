# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative '../values/publish_info'
require_relative '../values/sentimental_score'

module UFeeling
  module Videos
    module Entity
      # Provides access to comment data
      class Comments
        attr_reader :comments

        LIKE_WEIGHT = 0.2
        COMMENT_WEIGHT = 0.8

        def initialize(comments:)
          @comments = comments
        end

        def total_likes
          @comments.sum(&:like_count)
        end

        def weight_total_likes
          sum = total_likes
          @comments.map do |comment|
            weight = comment.like_count / sum
            value = comment.confidence + (weight * comment.confidence)
            { sentiment_name: comment.sentiment_name, reply_count: comment.total_reply_count, value: }
          end
        end

        def group_sentiments
          group = weight_total_likes.group_by { |sentiment| sentiment[:sentiment_name] }
          group.map do |key, value|
            total_replies = value.sum { |v| v[:reply_count] }
            count_sentiment = value.size
            total_weighted = value.sum { |v| v[:value] }
            { sentiment: key, total_replies:, count_sentiment:, total_weighted: }
          end
        end

        def final_score
          total_replies = group_sentiments.sum { |sentiment| sentiment[:total_replies] }
          total_count_sentiment = group_sentiments.sum { |sentiment| sentiment[:count_sentiment] }

          group_sentiments.map do |value|
            replies_weight = value[:total_replies] * LIKE_WEIGHT / total_replies
            count_weight = value[:count_sentiment] * COMMENT_WEIGHT / total_count_sentiment
            final_score = (replies_weight + count_weight).round(2)
            sentiment = value[:sentiment]
            { sentiment:, final_score: }
          end
        end
      end
    end
  end
end
