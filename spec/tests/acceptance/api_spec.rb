# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'
require 'rack/test'

def app
  UFeeling::App
end

describe 'Test API routes' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_youtube
    DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Root route' do
    it 'should successfully return root information' do
      get '/'
      _(last_response.status).must_equal 200

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'ok'
      _(body['message']).must_include 'api/v1'
    end
  end

  describe 'Add video route' do
    it 'should be able to add a video' do
      post "api/v1/videos/#{VIDEO_ID}"

      _(last_response.status).must_equal 201

      video = JSON.parse last_response.body
      _(video['title']).must_equal VIDEO_TITLE

      vid = UFeeling::Representer::Video
        .new(UFeeling::Representer::OpenStructWithLinks.new)
        .from_json last_response.body

      _(vid.links['self'].href).must_include 'http'
    end

    it 'should report error for invalid videos' do
      post 'api/v1/videos/adsf'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end

  describe 'Get a list of videos route' do
    it 'should be able to get the list of videos' do
      post "api/v1/videos/#{VIDEO_ID}"
      get 'api/v1/videos'

      _(last_response.status).must_equal 200

      videos = JSON.parse last_response.body
      _(videos['videos'].size).must_equal 1
      _(videos['videos'][0]['origin_id']).must_equal VIDEO_ID
      _(videos['videos'][0]['title']).must_equal VIDEO_TITLE
    end
  end

  describe 'Gets a video' do
    it 'should be able to get a video' do
      post "api/v1/videos/#{VIDEO_ID}"
      get "api/v1/videos/#{VIDEO_ID}"

      _(last_response.status).must_equal 200

      video = JSON.parse last_response.body
      _(video['origin_id']).must_equal VIDEO_ID
      _(video['title']).must_equal VIDEO_TITLE
    end
  end

  describe 'Get a comment from a video' do
    it 'should be able to get the comments of a video' do
      post "api/v1/videos/#{VIDEO_ID}"
      get "api/v1/videos/#{VIDEO_ID}/comments"

      _(last_response.status).must_equal 200

      comments = JSON.parse last_response.body
      _(comments['comments'][0]['origin_id']).must_equal COMMENT_ID
      _(comments['comments'][0]['text_display']).must_equal TEXT_DISPLAY
    end
  end

  describe 'Get a category from a list of categories' do
    it 'should be able to get the category of a list of categories' do
      post "api/v1/videos/#{VIDEO_ID}"
      get "api/v1/categories"

      _(last_response.status).must_equal 200

      categories = JSON.parse last_response.body
      _(categories['categories'][0]['origin_id']).must_equal CATEGORY_ID
      _(categories['categories'][0]['title']).must_equal CATEGORY_TITLE
    end
  end

end
