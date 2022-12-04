# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'video_representer'

module UFeeling
  module Representer
    # Represents list of videos for API output
    class VideosList < Roar::Decorator
      include Roar::JSON

      collection :videos, extend: Representer::Video,
                          class: Representer::OpenStructWithLinks
    end
  end
end
