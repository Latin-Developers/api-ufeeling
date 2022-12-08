# frozen_string_literal: true

module UFeeling
  module Videos
    # ? Should this be called Repositories ??
    module Repository
      # Repository for Categories
      class Categories
        def self.find_by_origin_id(origin_id)
          rebuild_entity Database::CategoryOrm.first(origin_id:)
        end

        def self.find_id(id)
          rebuild_entity Database::CategoryOrm.first(id:)
        end

        def self.find_title(title)
          rebuild_entity Database::CategoryOrm.first(title:)
        end

        def self.all
          categories = Database::CategoryOrm.all
          rebuild_many(categories)
        end

        def self.rebuild_entity(db_record)
          return nil unless db_record

          Entity::Category.new(
            id: db_record.id,
            origin_id: db_record.origin_id,
            title: db_record.title
          )
        end

        def self.rebuild_many(db_records)
          db_records.map do |db_member|
            Categories.rebuild_entity(db_member)
          end
        end

        def self.find_or_create(entity)
          Database::CategoryOrm.find_or_create(entity.to_attr_hash)
        end
      end
    end
  end
end
