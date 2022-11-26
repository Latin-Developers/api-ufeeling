# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:comments) do
      primary_key :id
      foreign_key :video_id, table: :videos
      foreign_key :author_channel_id, table: :authors  # Check if the name is author_channel_id
      foreign_key :sentiment_id, table: :sentiments
      Float       :sentimental_score
      String      :origin_id
      String      :video_origin_id
      String      :author_channel_origin_id
      String      :text_display
      String      :text_original
      Integer     :like_count
      Integer     :total_reply_count
      DateTime    :published_at
      String      :day
      String      :month
      String      :year
      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
