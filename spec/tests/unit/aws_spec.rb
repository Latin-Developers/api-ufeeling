# frozen_string_literal: true

require_relative '../../helpers/spec_helper'

describe 'Tests AWS API' do
  describe 'AWS Language Detection' do
    it 'HAPPY: should provide the language code of the language sample provided' do
      _(UFeeling::Videos::Mappers::AWSLanguage
        .new(AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
        .language(LANGUAGE_SAMPLE)[:language_code]).must_equal(LANGUAGE_SAMPLE_CODE)
    end

    it 'BAD: should set the fallback(default value) on exception when unauthorized' do
      _(UFeeling::Videos::Mappers::AWSLanguage
        .new(AWS_REGION, AWS_ACCESS_KEY_ID, 'BAD_ACCESS_KEY')
        .language(LANGUAGE_SAMPLE)[:language_code]).must_equal(LANGUAGE_DEFAULT)
    end
  end

  describe 'AWS Sentiment Detection' do
    it 'HAPPY: should provide the language sentiment of the language sample provided' do
      _(UFeeling::Videos::Mappers::AWSSentiment
        .new(AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
        .sentiment(LANGUAGE_SAMPLE, LANGUAGE_SAMPLE_CODE)[:sentiment_name]).must_equal(LANGUAGE_SAMPLE_SENTIMENT)
    end

    it 'BAD: should set the fallback(default value) on exception when unauthorized' do
      _(UFeeling::Videos::Mappers::AWSSentiment
        .new(AWS_REGION, AWS_ACCESS_KEY_ID, 'BAD_ACCESS_KEY')
        .sentiment(LANGUAGE_SAMPLE, LANGUAGE_SAMPLE_CODE)[:sentiment_name]).must_equal(SENTIMENT_DEFAULT)
    end
  end
end
