# frozen_string_literal: true

module UFeeling
  module Videos
    # ? Should this be called Repositories ??
    module Repository
      # Repository for Authors
      class Authors
        def self.find_by_origin_id(origin_id)
          rebuild_entity Database::AuthorOrm.first(origin_id:)
        end

        def self.find_id(id)
          rebuild_entity Database::AuthorOrm.first(id:)
        end

        def self.rebuild_entity(db_record)
          return nil unless db_record

          Entity::Author.new(
            id: db_record.id,
            origin_id: db_record.origin_id,
            name: db_record.name,
            thumbnail_url: db_record.thumbnail_url,
            description: db_record.description
          )
        end

        def self.rebuild_many(db_records)
          db_records.map do |db_member|
            Authors.rebuild_entity(db_member)
          end
        end

        def self.find_or_create(entity)
          Database::AuthorOrm.find_or_create(entity.to_attr_hash)
        end
      end
    end
  end
end
