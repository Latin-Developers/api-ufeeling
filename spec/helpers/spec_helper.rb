# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../../require_app'
require_app

YOUTUBE_API_KEY = UFeeling::App.config.YOUTUBE_API_KEY
VIDEO_ID = 'VBsB3FgqEx4'
VIDEO_TITLE = "Marvel's Midnight Suns Developer Livestream | Rise Up With The Midnight Suns"
