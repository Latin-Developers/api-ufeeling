# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:videos) do
      primary_key :id
      foreign_key :author_id, table: :authors
      foreign_key :category_id, table: :categories
      String      :origin_id # Check if we need it
      String      :origin_category_id # Check if we need it
      String      :origin_author_id # Check if we need it
      DateTime    :published_at
      String      :title
      String      :description
      Boolean     :comments_proccessed
      String      :thumbnail_url
      String      :duration
      String      :tags
      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
