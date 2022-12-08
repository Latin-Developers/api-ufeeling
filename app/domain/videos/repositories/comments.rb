# frozen_string_literal: true

module UFeeling
  module Videos
    # ? Should this be called Repositories ??
    module Repository
      # Repository for Categories
      class Comments
        def self.find_video_comments(video_origin_id)
          comments =  Database::CommentsOrm.where(video_origin_id:)
          rebuild_many comments
        end

        def self.find_id(id)
          rebuild_entity Database::CommentsOrm.first(id:)
        end

        def self.find_origin_id(origin_id)
          rebuild_entity Database::CommentsOrm.first(origin_id)
        end

        def self.find_ids(ids)
          ids.filter { |id| id }
            .map { |id| rebuild_entity Database::CommentsOrm.first(id:) }
            .filter { |comment| comment }
        end

        # rubocop:disable Metrics/MethodLength
        def self.rebuild_entity(db_record)
          return nil unless db_record

          Entity::Comment.new(
            id: db_record.id,
            video_id: db_record.video_id,
            author_channel_id: db_record.author_channel_id,
            origin_id: db_record.origin_id,
            video_origin_id: db_record.video_origin_id,
            author_channel_origin_id: db_record.author_channel_origin_id,
            text_display: db_record.text_display,
            text_original: db_record.text_original,
            like_count: db_record.like_count,
            total_reply_count: db_record.total_reply_count,
            sentiment:,
            published_info:
          )
        end
        # rubocop:enable Metrics/MethodLength

        def self.published_info(db_record)
          Entity::PublishedInfo.new(
            date: db_record.published_at,
            day: db_record.day,
            month: db_record.month,
            year: db_record.year
          )
        end

        def self.sentiment(db_record)
          Entity::SentimentalScore.new(
            sentiment_id: db_record.sentiment_id,
            sentiment_name: db_record.sentiment.sentiment_name,
            sentiment_score: db_record.sentiment_score
          )
        end

        def self.rebuild_many(db_records)
          db_records.map do |db_member|
            Comments.rebuild_entity(db_member)
          end
        end

        def self.find_or_create(entity)
          entity = fill_reference_ids(entity)
          Database::CommentsOrm.find_or_create(entity.to_attr_hash)
        end

        def self.fill_reference_ids(entity)
          video = video_from_origin_id(entity)
          author = author_from_origin_id(entity)
          sentiment = sentiment_from_name(entity)

          UFeeling::Videos::Entity::Comment.new(entity.to_h.merge(video_id: video.id,
                                                                  author_channel_id: author.id,
                                                                  sentiment: {
                                                                    sentiment_id: sentiment.id,
                                                                    sentiment_name: entity.sentiment.sentiment_name,
                                                                    sentiment_score: entity.sentiment.sentiment_score
                                                                  }))
        end

        def self.video_from_origin_id(entity)
          video = UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Video)
            .find_origin_id(entity.video_origin_id)

          unless video
            video = UFeeling::Videos::Mappers::ApiVideo.new(App.config.YOUTUBE_API_KEY)
              .video(entity.video_origin_id)

            video = Database::VideoOrm.find_or_create(video.to_attr_hash)
          end
          video
        end

        def self.author_from_origin_id(entity)
          author = UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Author)
            .find_origin_id(entity.author_channel_origin_id)

          unless author
            author = UFeeling::Videos::Mappers::ApiAuthor.new(App.config.YOUTUBE_API_KEY)
              .author(entity.author_channel_origin_id)

            author = Database::AuthorOrm.find_or_create(author.to_attr_hash)
          end
          author
        end

        def self.sentiment_from_name(entity)
          sentiment = UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Sentiment)
            .find_title(entity.sentiment.sentiment_name)

          unless sentiment
            sentiment = UFeeling::Videos::Entity::Sentiment.new(id: nil, sentiment: entity.sentiment.sentiment_name)
            sentiment = Database::SentimentOrm.create(sentiment.to_attr_hash)
          end
          sentiment
        end
      end
    end
  end
end
