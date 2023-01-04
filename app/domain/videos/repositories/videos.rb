# frozen_string_literal: true

module UFeeling
  module Videos
    # ? Should this be called Repositories ??
    module Repository
      # Repository for Categories
      class Videos
        def self.find_by_origin_id(origin_id)
          rebuild_entity Database::VideoOrm.first(origin_id:)
        end

        def self.find(video_ids, categories)
          videos = if video_ids.size.zero? && categories.size.zero?
                     Database::VideoOrm.all
                   elsif video_ids.size.zero?
                     Database::VideoOrm.where(origin_category_id: categories)
                   elsif categories.size.zero?
                     Database::VideoOrm.where(origin_id: video_ids)
                   else
                     Database::VideoOrm.where(origin_id: video_ids, origin_category_id: categories)
                   end

          videos.map { |video| rebuild_entity video }
        end

        def self.find_id(id)
          rebuild_entity Database::VideoOrm.first(id:)
        end

        def self.find_ids(ids)
          ids.filter { |id| id }
            .map { |id| rebuild_entity Database::VideoOrm.first(id:) }
            .filter { |video| video }
        end

        def self.find_title(title)
          rebuild_entity Database::VideoOrm.first(title:)
        end

        # rubocop:disable Metrics/MethodLength
        def self.rebuild_entity(db_record)
          return nil unless db_record

          Entity::Video.new(
            id: db_record.id,
            author_id: db_record.author_id,
            category_id: db_record.category_id,
            origin_id: db_record.origin_id,
            origin_category_id: db_record.origin_category_id,
            origin_author_id: db_record.origin_author_id,
            published_at: db_record.published_at,
            title: db_record.title,
            description: db_record.description,
            status: db_record.status,
            comment_count: db_record.comment_count,
            thumbnail_url: db_record.thumbnail_url,
            duration: db_record.duration,
            tags: db_record.tags
          )
        end
        # rubocop:enable Metrics/MethodLength

        def self.rebuild_many(db_records)
          db_records.map do |db_member|
            Videos.rebuild_entity(db_member)
          end
        end

        def self.find_or_create(entity)
          Database::VideoOrm.find_or_create(entity.to_attr_hash)
        end

        def self.update(entity)
          Database::VideoOrm.where(origin_id: entity.origin_id).update(entity.to_attr_hash)

          find_by_origin_id(entity.origin_id)
        end

        def self.category_from_origin_id(entity)
          category = UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Category)
            .find_by_origin_id(entity.origin_category_id)

          unless category
            category = UFeeling::Videos::Mappers::ApiCategory.new(App.config.YOUTUBE_API_KEY)
              .category(entity.origin_category_id)
            category = Database::CategoryOrm.find_or_create(category.to_attr_hash)
          end
          category
        end

        def self.author_from_origin_id(entity)
          author = UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Author)
            .find_by_origin_id(entity.origin_author_id)

          unless author
            author = UFeeling::Videos::Mappers::ApiAuthor.new(App.config.YOUTUBE_API_KEY)
              .author(entity.origin_author_id)
            author = Database::AuthorOrm.find_or_create(author.to_attr_hash)
          end
          author
        end
      end
    end
  end
end
