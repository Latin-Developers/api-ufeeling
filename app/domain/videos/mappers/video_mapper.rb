# frozen_string_literal: false

module UFeeling
  module Videos
    module Mappers
      # Data Mapper: Youtube Video -> Entity Video
      class ApiVideo
        def initialize(youtube_token, gateway_class = Youtube::Api)
          @token = youtube_token
          @gateway_class = gateway_class
          @gateway = @gateway_class.new(@token)
        end

        # !Deprecated
        def popular_videos(region)
          data_items = @gateway.popular_videos(region)
          data_items.map { |data| ApiVideo.build_entity(data) }
        end

        def details(video_id)
          data = @gateway.details(video_id)
          ApiVideo.build_entity(data)
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
            UFeeling::Videos::Entity::Video.new(
              id: nil,
              author_id: nil,
              category_id: nil,
              origin_id:,
              origin_category_id:,
              origin_author_id:,
              published_at:,
              title:,
              description:,
              thumbnail_url:,
              comment_count:,
              duration:,
              tags: nil,
              author: nil
            )
          end
          # rubocop:enable Metrics/MethodLength

          private

          def origin_id
            @data['id']
          end

          def published_at
            Time.parse(snippet['publishedAt'])
          end

          def origin_author_id
            snippet['channelId']
          end

          def title
            snippet['title']
          end

          def description
            snippet['description']
          end

          def thumbnail_url
            maxres_thumbnail ? maxres_thumbnail['url'] : default_thumbnail['url']
          end

          def default_thumbnail
            snippet['thumbnails']['default']
          end

          def maxres_thumbnail
            snippet['thumbnails']['maxres']
          end

          def origin_category_id
            snippet['categoryId']
          end

          def duration
            content_details['duration']
          end

          def view_count
            statistics['viewCount']
          end

          def like_count
            statistics['likeCount']
          end

          def favorite_count
            statistics['favoriteCount']
          end

          def comment_count
            statistics['commentCount'].to_i || 0
          end

          def snippet
            @data['snippet'] || {}
          end

          def content_details
            @data['contentDetails'] || {}
          end

          def statistics
            @data['statistics'] || {}
          end
        end
      end
    end
  end
end
