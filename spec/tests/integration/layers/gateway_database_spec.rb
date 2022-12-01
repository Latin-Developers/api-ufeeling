# frozen_string_literal: false

require_relative 'spec_helper'
require_relative 'helpers/vcr_helper'
require_relative 'helpers/database_helper'

describe 'Integration Tests of Youtube API and Database' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_youtube
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store project' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should save all the categories in the database' do
      categories = UFeeling::Videos::Mappers::ApiCategory
        .new(YOUTUBE_API_KEY)
        .categories(UFeeling::REGIONS[:MEXICO])

      categories.each do |category|
        UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Category).find_or_create(category)
      end
      categories_db = UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Category)
        .all

      _(categories_db.size).must_equal(categories.size)
    end

    it 'HAPPY: should a new video in the database' do
      video = UFeeling::Videos::Mappers::ApiVideo.new(YOUTUBE_API_KEY).details('LZx22ZcMPy0')
      UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Video).find_or_create(video)

      video_db = UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Video)
        .find_origin_id(video.origin_id)

      _(video_db.origin_id).must_equal(video.origin_id)
    end
  end
end
