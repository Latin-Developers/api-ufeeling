# frozen_string_literal: true

require 'roda'

module UFeeling
  # Web App
  class App < Roda # rubocop:disable Metrics/ClassLength
    plugin :halt
    plugin :caching
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :common_logger, $stderr

    route do |routing|
      response['Content-Type'] = 'application/json'

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
        routing.on 'categories' do
          # [GET] /categories
          routing.get do
            result = Services::GetCategories.new.call

            if result.failure?
              failed = Representer::HttpResponse.new(result.failure)
              routing.halt failed.http_status_code, failed.to_json
            end

            http_response = Representer::HttpResponse.new(result.value!)
            response.status = http_response.http_status_code
            Representer::CategoriesList.new(result.value!.message).to_json
          end
        end

        # [...] /videos/
        routing.on 'videos' do
          routing.is do
            # [GET] /videos?ids=&categories=
            # Returns the list of videos
            # video_ids = list of origin ids that needs to be filter
            # categories = list of category ids that needs to be filter
            routing.get do
              App.configure :production do
                response.cache_control public: true, max_age: 300
              end

              filters = Request::EncodedVideoList.new(routing.params)
              result = Services::ListVideos.new.call(filters:)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::VideosList.new(result.value!.message).to_json
            end
          end

          # [...]  /videos/:video_origin_id
          routing.on String do |video_origin_id|
            routing.is do
              # [POST]  /videos/:video_origin_id
              # Adds a new video into the database and obtains the comments
              # video_origin_id = id of the video in youtube
              routing.post do
                result = Services::AddVideo.new.call(video_id: video_origin_id)
                if result.failure?
                  failed = Representer::HttpResponse.new(result.failure)
                  routing.halt failed.http_status_code, failed.to_json
                end

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code
                Representer::Video.new(result.value!.message).to_json
              end

              # [PUT]  /videos/:video_origin_id
              # Updates the information of a video and its comments
              # *@video_origin_id = id of the video in youtube
              routing.put do
                result = Services::UpdateVideo.new.call(video_id: video_origin_id)

                if result.failure?
                  failed = Representer::HttpResponse.new(result.failure)
                  routing.halt failed.http_status_code, failed.to_json
                end

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code
                Representer::Video.new(result.value!.message).to_json
              end

              # [GET]  /videos/:video_origin_id
              # Returns the basic information of a video
              # video_origin_id = id of the video in youtube
              # Responsible Julian
              routing.get do
                result = Services::AnalyzeVideo.new.call(video_id: video_origin_id)

                if result.failure?
                  failed = Representer::HttpResponse.new(result.failure)
                  routing.halt failed.http_status_code, failed.to_json
                end

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code
                Representer::Video.new(result.value!.message).to_json
              end
            end

            # [...]  /videos/:video_origin_id/comments
            routing.on 'comments' do
              # [GET]  /videos/:video_origin_id/comments
              # Gets the list of comments of a video
              # Responsible Julian
              routing.get do
                App.configure :production do
                  response.cache_control public: true, max_age: 300
                end
                result = Services::GetComments.new.call(video_id: video_origin_id)

                if result.failure?
                  failed = Representer::HttpResponse.new(result.failure)
                  routing.halt failed.http_status_code, failed.to_json
                end

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code
                Representer::CommentsList.new(result.value!.message).to_json
              end

              routing.post do
                result = Services::AnalyzeComments.new.call(video_id: video_origin_id, lambda: nil)

                if result.failure?
                  failed = Representer::HttpResponse.new(result.failure)
                  routing.halt failed.http_status_code, failed.to_json
                end

                http_response = Representer::HttpResponse.new(result.value!)
                response.status = http_response.http_status_code
                Representer::Video.new(result.value!.message).to_json
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
