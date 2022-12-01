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

      proj = UFeeling::Representer::Video.new(UFeeling::Representer::OpenStructWithLinks.new).from_json last_response.body

      _(proj.links['self'].href).must_include 'http'
    end

    it 'should report error for invalid projects' do
      post 'api/v1/videos/adsf'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end
end
