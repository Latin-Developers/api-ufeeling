# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:videos_log) do
      primary_key :id
      foreign_key :video_id, :videos
      foreign_key :sentiment_id, table: :sentiments
      Integer     :view_count
      Integer     :like_count
      Integer     :favorite_count
      Integer     :comment_count
      DateTime    :date_info
      Integer     :day
      Integer     :month
      Integer     :year
      Float       :sentiment_score
      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
