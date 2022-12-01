# frozen_string_literal: true

require 'roda'

module UFeeling
  # Web App
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :common_logger, $stderr

    route do |routing|
      # [GET] /
      # Validate if the api is alive
      routing.root do
        message = "UFeeling API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message:)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        # [...] /categories
        routing on 'categories' do
          # [GET] /categories
          # TODO
          routing.get do
          end
        end

        # [...] /videos/
        routing.on 'videos' do
          routing.is do
            # [GET] /videos?ids=&categories=
            # Returns the list of videos
            # ids = list of origin ids that needs to be filter
            # categories = list of category ids that needs to be filter
            # TODO
            routing.get do
            end
          end

          # [...]  /videos/:video_origin_id
          routing.on String do |_video_origin_id|
            routing.is do
              # [POST]  /videos/:video_origin_id
              # Adds a new video into the database and obtains the comments
              # vodeo_origin_id = id of the video in youtube
              # TODO
              routing.post do
              end

              # [PUT]  /videos/:video_origin_id
              # Updates the information of a videos and its comments
              # vodeo_origin_id = id of the video in youtube
              # TODO
              routing.post do
              end

              # [GET]  /videos/:video_origin_id
              # Returns the basic information of a video
              # vodeo_origin_id = id of the video in youtube
              # TODO
              routing.get do
              end
            end

            # [...]  /videos/:video_origin_id/comments
            routing.on 'comments' do
              # [GET]  /videos/:video_origin_id/comments
              # Gets the list of comments of a video
              # TODO
              routing.get do
              end
            end

            # [...] /videos/:video_origin_id/sentiments
            routing.on 'sentiments' do
              # [...] /videos/:video_origin_id/sentimens/summary
              routing.on 'summary' do
                # [GET] /videos/:video_origin_id/sentimens/summary
                # TODO
                routing.get do
                end
              end

              # [...] /videos/:video_origin_id/sentimens/trend
              routing.on 'trend' do
                # [GET] /videos/:video_origin_id/sentimens/summary
                # TODO
                routing.get do
                end
              end
            end
          end
        end
      end
    end
  end
end
