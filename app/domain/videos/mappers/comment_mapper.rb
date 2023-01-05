# frozen_string_literal: false

require 'concurrent'
require 'vader_sentiment_ruby'

module UFeeling
  module Videos
    module Mappers
      # Data Mapper: Youtube Video -> Entity Video
      class ApiComment
        def initialize(youtube_token, gateway_class = Youtube::Api)
          @token = youtube_token
          @gateway_class = gateway_class
          @gateway = @gateway_class.new(@token)
        end

        def comments(video_id, current_page_token = '')
          comments_data = @gateway.comments(video_id, current_page_token)

          comments = comments_data[:items].map do |data|
            Concurrent::Promise.execute do
              ApiComment.build_entity(data)
            end
          end.map(&:value)

          { comments:, next_page_token: comments_data[:next_page_token] }
        end

        def self.build_entity(data)
          DataMapper.new(data).build_entity
        end

        # Extracts entity specific elements from data structure
        class DataMapper
          def initialize(data)
            @data = data
          end

          # rubocop:disable Metrics/MethodLength
          def build_entity
            UFeeling::Videos::Entity::Comment.new(
              id: nil,
              video_id: nil,
              author_channel_id: nil,
              sentiment:,
              origin_id:,
              video_origin_id:,
              author_channel_origin_id:,
              text_display:,
              text_original:,
              like_count:,
              total_reply_count:,
              published_info:,
              language_name:,
              language_code:,
              language_reliable:,
              comment_replies:,
              author: nil
            )
          end
          # rubocop:enable Metrics/MethodLength

          private

          def origin_id
            @data['id']
          end

          def video_origin_id
            top_level_comment_snippet['videoId']
          end

          def text_display
            top_level_comment_snippet['textDisplay']
          end

          def text_original
            top_level_comment_snippet['textOriginal']
          end

          def like_count
            top_level_comment_snippet['likeCount']
          end

          def published_info
            UFeeling::Videos::Values::PublishedInfo.new(
              published_at:,
              year:,
              month:,
              day:
            )
          end

          def published_at
            Time.parse(top_level_comment_snippet['publishedAt'])
          end

          def year
            published_at.year
          end

          def month
            published_at.month
          end

          def day
            published_at.day
          end

          def sentiment
            analysis = VaderSentimentRuby.polarity_scores(text_display)
            analysis.delete(:compound)
            score = analysis.max_by { |_k, v| v }
            UFeeling::Videos::Values::SentimentalScore.new(
              sentiment_id: nil,
              sentiment_name: score[0].to_s,
              sentiment_score: score[1]
            )
          end

          def total_reply_count
            comment_replies.size
          end

          def comment_replies
            replies_comments.map { |replies_comment| ApiComment.build_entity(replies_comment) }
          end

          def replies
            @data['replies'] || {}
          end

          def replies_comments
            replies['comments'] || []
          end

          def snippet
            @data['snippet'] || {}
          end

          def top_level_comment
            snippet['topLevelComment'] || {}
          end

          def top_level_comment_snippet
            top_level_comment['snippet'] || snippet
          end

          def author_channel_origin_id
            top_level_comment_snippet['authorChannelId']['value'] || {}
          end

          def language_name
            analysis = CLD.detect_language(text_display)
            UFeeling::Videos::Values::LanguageDetection.new(
              language_name: analysis.values[0],
              language_code: analysis.values[1],
              language_reliable: analysis.values[2]
            )
          end
        end
      end
    end
  end
end
