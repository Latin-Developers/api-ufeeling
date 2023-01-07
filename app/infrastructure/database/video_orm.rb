# frozen_string_literal: true

require 'sequel'

module UFeeling
  module Database
    # Object-Relational Mapper for video entities
    class VideoOrm < Sequel::Model(:videos)
      many_to_one   :category,
                    class: :'UFeeling::Database::CategoryOrm'

      many_to_one   :author,
                    class: :'UFeeling::Database::AuthorOrm'

      one_to_many   :comments,
                    class: :'UFeeling::Database::CommentsOrm',
                    key: :video_id

      one_to_many :logs,
                  class: :'UFeeling::Database::VideoLogOrm',
                  key: :video_id

      many_to_one :sentiment,
                  class: :'UFeeling::Database::SentimentOrm'

      plugin :association_dependencies, logs: :destroy
      plugin :timestamps, update_on_create: true

      def self.find_or_create(video_info)
        first(origin_id: video_info[:origin_id]) || create(video_info)
      end

      def self.update(video_info)
        update(video_info)
      end
    end
  end
end
