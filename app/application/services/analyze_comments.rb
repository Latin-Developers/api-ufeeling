# frozen_string_literal: true

require 'dry/monads'
require 'dry/transaction'

module UFeeling
  module Services
    # Retrieves array of all listed videos entities
    class AnalyzeComments
      include Dry::Transaction

      step :obtain_analize_comments
      step :update_video_status

      private

      COMMENTS_DB_ERR_MSG = 'Having trouble saving comments in the database'
      YT_COMMENTS_ERROR = 'Having trouble getting comments from youtube'
      VIDEO_DB_ERR_MSG = 'Having trouble updating video in the database'

      def obtain_analize_comments(input)
        obtain_comments(input, true)
        Success(input)
        # rescue StandardError => e
        #   puts "Error obtaining comments: #{e}"
        # Failure(Response::ApiResult.new(status: :internal_error, message: YT_COMMENTS_ERROR))
      end

      def obtain_comments(input, first_call, current_page_token = '', counter = 0)
        input[:lambda]&.call('YOUTUBE', counter)
        return unless (first_call || current_page_token) && counter < 100

        comments_response = comments_from_youtube(input, current_page_token)
        # detect language
        comments_with_sentiment = detect_comments_sentiments(comments_response[:comments])
        save_comments_db(comments_with_sentiment)
        obtain_comments(input, false, comments_response[:next_page_token], counter + comments_with_sentiment.size)
      end

      def comments_from_youtube(input, current_page_token)
        UFeeling::Videos::Mappers::ApiComment
          .new(UFeeling::App.config.YOUTUBE_API_KEY)
          .comments(input[:video_id], current_page_token)
      end

      def detect_comments_sentiments(comments)
        comments.map do |comment|
          sentiment = UFeeling::Videos::Mappers::AWSSentiment
            .new(UFeeling::App.config.AWS_REGION, App.config.AWS_ACCESS_KEY_ID, App.config.AWS_SECRET_ACCESS_KEY)
            .sentiment(comment[:text_display], comment[:language][:language_code])
          UFeeling::Videos::Entity::Comment.new(comment.to_h.merge(sentiment: sentiment.to_h))
        end
      end

      def save_comments_db(comments)
        UFeeling::Videos::Repository::For
          .klass(UFeeling::Videos::Entity::Comment)
          .find_or_create_many(comments)
      end

      def update_video_status(input)
        video = video_in_database(input)
        video = UFeeling::Videos::Entity::Video.new(video.to_h.merge(status: 'completed'))

        UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Video)
          .update(video)

        Success(Response::ApiResult.new(status: :ok, message: video))
      rescue StandardError => e
        puts "Error executing worker: #{e}"
        Failure(Response::ApiResult.new(status: :internal_error, message: VIDEO_DB_ERR_MSG))
      end

      def video_in_database(input)
        Videos::Repository::For.klass(Videos::Entity::Video)
          .find_by_origin_id(input[:video_id])
      end
    end
  end
end
