# frozen_string_literal: true

require 'vader_sentiment_ruby'

a = VaderSentimentRuby.polarity_scores('odio completamente esto')

puts a
