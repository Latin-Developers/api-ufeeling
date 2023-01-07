# frozen_string_literal: true

require 'sequel'

module UFeeling
  module Database
    # Object Relational Mapper for author entities
    class SentimentOrm < Sequel::Model(:sentiments)
      one_to_many :comments,
                  class: :'UFeeling::Database::CommentsOrm',
                  key: :sentiment_id

      one_to_many :videos,
                  class: :'UFeeling::Database::VideoOrmOrm',
                  key: :sentiment_id

      one_to_many :logs,
                  class: :'UFeeling::Database::VideoLogOrm',
                  key: :sentiment_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(sentiment_info)
        first(origin_id: sentiment_info[:origin_id]) || create(sentiment_info)
      end
    end
  end
end
