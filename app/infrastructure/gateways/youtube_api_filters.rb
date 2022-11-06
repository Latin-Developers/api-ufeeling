# frozen_string_literal: true

require_relative 'youtube_constants'

module UFeeling
  module Youtube
    # YoutubeAPI Filters
    class ApiFilters
      def self.categories(region)
        { regionCode: region }
      end

      def self.popular_videos(region)
        {
          regionCode: region,
          part: PATH_FILTERS[:SNIPPET],
          chart: CHART_FILTERS[:MOST_POPULAR]
        }
      end

      def self.comments(video_id)
        {
          part: "#{PATH_FILTERS[:SNIPPET]},#{PATH_FILTERS[:REPLIES]}",
          videoId: video_id
        }
      end

      def self.details(video_id)
        {
          part: "#{PATH_FILTERS[:SNIPPET]},#{PATH_FILTERS[:STATISTICS]},#{PATH_FILTERS[:CONTENT_DETAILS]}",
          id: video_id
        }
      end
    end
  end
end
