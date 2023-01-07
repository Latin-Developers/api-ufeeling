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
    it 'HAPPY: should successfully return root information' do
      get '/'
      _(last_response.status).must_equal 200

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'ok'
      _(body['message']).must_include 'api/v1'
    end
  end

  describe 'Add video route' do
    it 'HAPPY: should be able to add a video' do
      post "api/v1/videos/#{VIDEO_ID}"

      _(last_response.status).must_equal 201

      video = JSON.parse last_response.body
      _(video['title']).must_equal VIDEO_TITLE

      vid = UFeeling::Representer::Video
        .new(UFeeling::Representer::OpenStructWithLinks.new)
        .from_json last_response.body

      _(vid.links['self'].href).must_include 'http'
    end

    it 'SAD: Should report error for invalid videos' do
      post 'api/v1/videos/adsf'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end

  describe 'Get a list of videos route' do
    it 'HAPPY: should be able to get the list of videos' do
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
    it 'HAPPY: should return a processing status when a new video is requested' do
      post "api/v1/videos/#{VIDEO_ID}"
      get "api/v1/videos/#{VIDEO_ID}"

      _(last_response.status).must_equal 202
    end
  end

  describe 'Update a video' do
    it 'HAPPY: should be able to update a video' do
      # Get and store a video
      post "api/v1/videos/#{VIDEO_ID}"

      # Manually modify the test video
      UFeeling::Database::VideoOrm.where(origin_id: VIDEO_ID).update(title: 'Test Tittle')

      # Update the video
      put "api/v1/videos/#{VIDEO_ID}"

      # Validate Origin_id and tittle between both records.

      _(last_response.status).must_equal 202
    end

    it 'SAD: Should report error for not existing video' do
      post 'api/v1/videos/adsf'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end

  describe 'Get a comment from a video' do
    it 'should be able to get the comments of a video' do
      post "api/v1/videos/#{VIDEO_ID}"
      get "api/v1/videos/#{VIDEO_ID}"

      sleep(10)
      get "api/v1/videos/#{VIDEO_ID}/comments"

      _(last_response.status).must_equal 200

      comments = JSON.parse last_response.body
      _(comments['comments'].size).must_be :>, 0
    end
  end

  describe 'Get a category from a list of categories' do
    it 'should be able to get the category of a list of categories' do
      post "api/v1/videos/#{VIDEO_ID}"
      get 'api/v1/categories'

      _(last_response.status).must_equal 200

      categories = JSON.parse last_response.body
      _(categories['categories'][0]['origin_id']).must_equal CATEGORY_ID
      _(categories['categories'][0]['title']).must_equal CATEGORY_TITLE
    end
  end
end
