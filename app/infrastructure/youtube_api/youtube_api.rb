# frozen_string_literal: true

require 'http'
require 'pry'

module UFeeling
  module Youtube
    # Library for Youtube Web API
    class Api
      YOUTUBE_API_PATH =
        {
          VIDEO_CATEGORIES: 'videoCategories',
          AUTHORS: 'channels',
          VIDEOS: 'videos',
          COMMENTS: 'commentThreads'
        }.freeze

      def initialize(token)
        @token = token
      end

      def video_resource(resource_type, filters)
        youtube_response = YoutubeHttpRequest.new(YOUTUBE_API_PATH[resource_type], @token, filters).http_get
        { items: youtube_response['items'], next_page_token: youtube_response['nextPageToken'] }
      end

      # TODO: authors

      def author(id)
        video_resource(:AUTHORS, ApiFilters.author(id))[:items].first
      end

      def categories(region)
        video_resource(:VIDEO_CATEGORIES, ApiFilters.categories(region))[:items]
      end

      def category(id)
        video_resource(:VIDEO_CATEGORIES, ApiFilters.category(id))[:items].first
      end

      # !Deprecated, not needed for the video scope
      def popular_videos(region)
        video_resource(:VIDEOS, ApiFilters.popular_videos(region))[:items]
      end

      def comments(video_id, next_page_token)
        video_resource(:COMMENTS, ApiFilters.comments(video_id, next_page_token))
      end

      def details(video_id)
        video_resource(:VIDEOS, ApiFilters.details(video_id))[:items].first
      end
    end
  end
end
