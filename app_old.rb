# frozen_string_literal: true

require 'roda'

module UFeeling
  # Web App
  class App_OLD < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets', css: 'style.css'
    plugin :common_logger, $stderr

    route do |routing|
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'
      routing.public
      # [GET]   /                             Home
      # [POST]  /videos?url=                  Analyze a new video
      # [GET]   /videos/:video_id             Gets the analysis of a video
      # [GET]   /videos/:video_id/comments    Gets the analysis of a video including the list of top comments

      # [GET] /
      routing.root do
        # Get cookie viewer's previously seen videos
        session[:watching] ||= []

        # Load previously searched videos
        videos = UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Video)
          .find_ids(session[:watching])

        session[:watching] = videos.map(&:id)

        flash.now[:notice] = 'Search for a video to get started' if videos.none?

        viewed_videos = Views::VideoList.new(videos)
        view 'home', locals: { videos: viewed_videos }
      end

      # [...] /videos/
      routing.on 'videos' do
        routing.is do
          # [POST]  /videos?url=
          routing.post do
            url_request = Forms::NewVideo.new.call(routing.params)
            new_video = Services::AddVideo.new.call(url_request)

            if new_video.failure?
              flash[:error] = new_video.failure
              routing.redirect '/'
            end

            video = new_video.value!
            session[:watching].insert(0, video.id).uniq!
            flash[:notice] = 'New video added'
            routing.redirect "videos/#{video.origin_id}"
          end
        end

        # [...]  /videos/:video_origin_id
        routing.on String do |video_origin_id|
          # [GET]  /videos/:video_origin_id
          routing.is do
            routing.get do
              # Get Video from database
              video = Services::GetVideo.new.call(video_origin_id)

              if video.failure?
                flash[:error] = video.failure
                routing.redirect '/'
              end

              video_info = Views::VideoInfo.new(video.value![:video], video.value![:comments])

              # Show viewer the video
              view 'video', locals: { video_info: }
            end
          end

          # [...]  /videos/:video_origin_id/comments
          routing.on 'comments' do
            # [GET]  /videos/:video_origin_id/comments
            # routing.get {}
          end
        end
      end
    end
  end
end
