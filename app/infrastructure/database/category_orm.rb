# frozen_string_literal: true

require 'sequel'

module UFeeling
  module Database
    # Object-Relational Mapper for categories entities
    class CategoryOrm < Sequel::Model(:categories)
      one_to_many :videos,
                  class: :'UFeeling::Database::VideoOrm',
                  key: :category_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(category_info)
        first(origin_id: category_info[:origin_id]) || create(category_info)
      end
    end
  end
end
