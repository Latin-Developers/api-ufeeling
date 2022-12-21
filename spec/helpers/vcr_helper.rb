# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
module VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  CASSETTE_FILE = 'youtube_api'

  def self.setup_vcr
    VCR.configure do |c|
      c.cassette_library_dir = CASSETTES_FOLDER
      c.hook_into :webmock
      vcr_config.ignore_localhost = true # for acceptance tests
      vcr_config.ignore_hosts 'sqs.us-east-1.amazonaws.com'
      vcr_config.ignore_hosts 'sqs.ap-northeast-1.amazonaws.com'
    end
  end

  def self.configure_vcr_for_youtube
    VCR.configure do |c|
      c.filter_sensitive_data('<YOUTUBE_API_KEY>') { YOUTUBE_API_KEY }
      c.filter_sensitive_data('<YOUTUBE_API_KEY_ESC>') { CGI.escape(YOUTUBE_API_KEY) }
    end

    VCR.insert_cassette(
      CASSETTE_FILE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
