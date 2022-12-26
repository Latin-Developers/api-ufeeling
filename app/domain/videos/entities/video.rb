# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module UFeeling
  module Videos
    module Entity
      # Provides access to Category data
      class Video < Dry::Struct
        include Dry.Types

        attribute :id,                      Integer.optional
        attribute :author_id,               Integer.optional
        attribute :category_id,             Integer.optional
        attribute :origin_id,               Strict::String
        attribute :origin_category_id,      Strict::String
        attribute :origin_author_id,        Strict::String
        attribute :published_at,            Strict::Time
        attribute :title,                   Strict::String
        attribute :description,             Strict::String
        attribute :thumbnail_url,           String.optional
        attribute :status,                  String.default('New')
        attribute :comment_count,           Integer.optional
        attribute :duration,                String.optional
        attribute :tags,                    String.optional

        def to_attr_hash
          to_hash.except(:id)
        end

        def processing?
          status == 'processing'
        end

        def completed?
          status == 'completed'
        end
      end
    end
  end
end
