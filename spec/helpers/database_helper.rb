# frozen_string_literal: true

# Helper to clean database during test runs
module DatabaseHelper
  def self.wipe_database
    # Ignore foreign key constraints when wiping tables
    UFeeling::App.DB.run('PRAGMA foreign_keys = OFF')
    UFeeling::Database::VideoLogOrm.map(&:destroy)
    UFeeling::Database::CommentsOrm.map(&:destroy)
    UFeeling::Database::VideoOrm.map(&:destroy)
    UFeeling::Database::SentimentOrm.map(&:destroy)
    UFeeling::Database::AuthorOrm.map(&:destroy)
    UFeeling::Database::CategoryOrm.map(&:destroy)
    UFeeling::App.DB.run('PRAGMA foreign_keys = ON')
  end
end
