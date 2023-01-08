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

        def initialize(comments)
          @comments = comments
        end

        def calculate_sentiment
          sentiment = final_score.max_by { |e| e[:score] }
          Values::SentimentalScore.new(
            sentiment_id: nil,
            sentiment_name: sentiment[:sentiment],
            sentiment_score: sentiment[:score]
          )
        end

        private

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
            replies_weight = replies_weight(value[:total_replies], total_replies)
            count_weight = count_weight(value[:count_sentiment], total_count_sentiment)
            score = replies_weight + count_weight
            { sentiment: value[:sentiment], score: }
          end
        end

        def replies_weight(sentiment_replies, total_replies)
          total_replies.zero? ? 0 : sentiment_replies * LIKE_WEIGHT / total_replies
        end

        def count_weight(count_sentiment, total_count_sentiment)
          total_count_sentiment.zero? ? 0 : count_sentiment * COMMENT_WEIGHT / total_count_sentiment
        end
      end
    end
  end
end
