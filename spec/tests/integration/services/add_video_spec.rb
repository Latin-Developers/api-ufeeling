# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'

describe 'Tests add_video service' do
  describe 'Add video service' do
    it 'HAPPY: should insert the sample video in the database' do
      # Insert in DB, then verify if it was successfull
      UFeeling::Services::AddVideo.new.call(video_id: VIDEO_ID)
      _(UFeeling::Videos::Repository::For.klass(UFeeling::Videos::Entity::Video).find_by_origin_id(VIDEO_ID)[:title])
        .must_equal(VIDEO_TITLE)
    end

    it 'BAD: should raise an error when video id does not exist' do
      result = UFeeling::Services::AddVideo.new.call(video_id: 'BAD_VIDEO_ID')
      _(result.failure?).must_equal(true)
    end
  end
end
