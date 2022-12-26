# frozen_string_literal: true

require_relative 'require_app'
require 'faye'
require_app

use Faye::RackAdapter, mount: '/faye', timeout: 25
run UFeeling::App.freeze.app
