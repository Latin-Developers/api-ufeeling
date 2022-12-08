# frozen_string_literal: true

require 'dry/transaction'

module UFeeling
  module Services
    # Transaction to store a video with comments from Youtube API to database
    class AddVideo
      include Dry::Transaction

      step :get_video
      step :add_video_to_db
      step :get_comments
      step :add_comments_to_db

      private

      DB_ERR_MSG = 'Having trouble accessing the database'
      YT_NOT_FOUND_MSG = 'Could not find video in youtube'
      YT_COMMENTS_ERROR = 'Having trouble getting comments from youtube'

      # Get video from Youtube
      def get_video(input)
        if (video = video_in_database(input))
          input[:local_video] = video
        else
          input[:remote_video] = video_from_origin(input)
        end
        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def add_video_to_db(input)
        # Add video to database
        video = if (new_video = input[:remote_video])
                  Videos::Repository::For.klass(Videos::Entity::Video).find_or_create(new_video)
                else
                  input[:local_video]
                end
        Success(video:)
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Get comments from Youtube (Julian added)
      # TODO: Verificar el paginado de los comentarios
      def get_comments(input)
        input[:comments] = Videos::Mappers::ApiComment
          .new(App.config.YOUTUBE_API_KEY)
          .comments(input[:video][:origin_id])

        Success(input)
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: YT_COMMENTS_ERROR))
      end

      # Add comments to database
      # TODO: Verificar actualizacion de comentarios. (Reprocesar el sentimiento?)
      def add_comments_to_db(input)
        input[:comments].each do |comment|
          Videos::Repository::For
            .klass(Videos::Entity::Comment)
            .find_or_create(comment)
        end
        Success(Response::ApiResult.new(status: :created, message: input[:video]))
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # Support methods that other services could use

      def video_from_origin(input)
        Videos::Mappers::ApiVideo
          .new(App.config.YOUTUBE_API_KEY).details(input[:video_id])
      rescue StandardError
        raise YT_NOT_FOUND_MSG
      end

      def video_in_database(input)
        Videos::Repository::For.klass(Videos::Entity::Video)
          .find_by_origin_id(input[:video_id])
      end

      def comment_in_database(input)
        Videos::Repository::For.klass(Videos::Entity::Video)
          .find_by_origin_id(input[:video_id])
      end
    end
  end
end
