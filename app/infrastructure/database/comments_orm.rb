# frozen_string_literal: true

require 'sequel'

module UFeeling
  module Database
    # Object-Relational Mapper for comment logs entities
    class CommentsOrm < Sequel::Model(:comments)
      many_to_one :video,
                  class: :'UFeeling::Database::VideoOrm'

      many_to_one :author,
                  class: :'UFeeling::Database::AuthorOrm',
                  key: :author_channel_id

      many_to_one :sentiment,
                  class: :'UFeeling::Database::SentimentOrm'

      plugin :timestamps, update_on_create: true
    end
  end
end
