# frozen_string_literal: true

require_relative 'spec_helper'
require_relative 'helpers/vcr_helper'

describe 'Tests Youtube API library' do
  VcrHelper.setup_vcr
  before do
    VcrHelper.configure_vcr_for_youtube
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Youtube categories information' do
    it 'HAPPY: should provide list of youtube video categories' do
      categories = UFeeling::Videos::Mappers::ApiCategory.new(YOUTUBE_API_KEY).categories(UFeeling::REGIONS[:GUATEMALA])
      _(categories.size).must_be :>, 0
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        UFeeling::Videos::Mappers::ApiCategory.new('BAD_TOKEN')
        .categories(UFeeling::REGIONS[:GUATEMALA])
      end).must_raise Errors::BadRequest
    end
  end

  describe 'Youtube videos information' do
    it 'HAPPY: should provide list of youtube videos' do
      videos = UFeeling::Videos::Mappers::ApiVideo.new(YOUTUBE_API_KEY).popular_videos(UFeeling::REGIONS[:GUATEMALA])
      _(videos.size).must_be :>, 0
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        UFeeling::Videos::Mappers::ApiVideo.new('BAD_TOKEN').popular_videos(UFeeling::REGIONS[:GUATEMALA])
      end).must_raise Errors::BadRequest
    end
  end

  describe 'Youtube comments information' do
    it 'HAPPY: should provide list of youtube comments' do
      comments = UFeeling::Videos::Mappers::ApiComment.new(YOUTUBE_API_KEY).comments('ggGINmj5EQE')
      _(comments.size).must_be :>, 0
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        UFeeling::Videos::Mappers::ApiComment.new('BAD_TOKEN').comments('ggGINmj5EQE')
      end).must_raise Errors::BadRequest
    end
  end

  describe 'Youtube detail video information' do
    it 'HAPPY: should provide list of youtube video detail' do
      details = UFeeling::Videos::Mappers::ApiVideo.new(YOUTUBE_API_KEY).details('ggGINmj5EQE')
      _(details.origin_id).must_equal 'ggGINmj5EQE'
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        UFeeling::Videos::Mappers::ApiVideo.new('BAD_TOKEN').details('ggGINmj5EQE')
      end).must_raise Errors::BadRequest
    end
  end

  describe 'Youtube category information' do
    it 'HAPPY: should provide list of youtube category detail' do
      details = UFeeling::Videos::Mappers::ApiCategory.new(YOUTUBE_API_KEY).category('1')
      _(details.origin_id).must_equal '1'
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        UFeeling::Videos::Mappers::ApiCategory.new('BAD_TOKEN').category('1')
      end).must_raise Errors::BadRequest
    end
  end

  describe 'Youtube channel (author) information' do
    it 'HAPPY: should provide list of youtube channel (author) detail' do
      details = UFeeling::Videos::Mappers::ApiAuthor.new(YOUTUBE_API_KEY).author('UCc96wBaIMkjH2JedZ5LIO4g')
      _(details.origin_id).must_equal 'UCc96wBaIMkjH2JedZ5LIO4g'
    end

    it 'SAD: should raise exception when unauthorized' do
      _(proc do
        UFeeling::Videos::Mappers::ApiAuthor.new('BAD_TOKEN').author('UCc96wBaIMkjH2JedZ5LIO4g')
      end).must_raise Errors::BadRequest
    end
  end
end
