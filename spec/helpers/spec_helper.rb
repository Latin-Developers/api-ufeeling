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
AUTHOR_ID = 'UCc96wBaIMkjH2JedZ5LIO4g'
VIDEO_ID = 'VBsB3FgqEx4'
VIDEO_IDS = %w[VBsB3FgqEx4 9reTrHdL7rQ].freeze
VIDEO_TITLE = "Marvel's Midnight Suns Developer Livestream | Rise Up With The Midnight Suns"
COMMENT_ID = 'Ugympyji94VDoTJfYjx4AaABAg'
TEXT_DISPLAY = 'Easily destroy all DCU and DCEU, WB sold DC to China’s Tencent'
CATEGORY_ID = '20'
CATEGORY_TITLE = 'Gaming'
LANGUAGE_SAMPLE_CODE = 'es'
LANGUAGE_NAME = 'Spanish'
LANGUAGE_SAMPLE = 'Estoy muy feliz por este texto de prueba :)'
LANGUAGE_DEFAULT = 'en'
LANGUAGE_SAMPLE_SENTIMENT = 'positive'
SENTIMENT_DEFAULT = 'neutral'
AWS_REGION = UFeeling::App.config.AWS_REGION
AWS_ACCESS_KEY_ID = UFeeling::App.config.AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY = UFeeling::App.config.AWS_SECRET_ACCESS_KEY
