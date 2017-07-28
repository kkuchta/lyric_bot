$stdout.sync = true
puts 'Booting up'

require 'dotenv'
require 'twitter'

Dotenv.load

if ENV['ENV'] == 'development'
  require 'pry-byebug'
end

require_relative './lyric_checker'
require_relative './tweet'

stream = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_SECRET']
end
rest = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_SECRET']
end

puts 'initializing corpus'
corpus = File.read('./hamilton_corpus.txt')
lyric_checker = LyricChecker.new(corpus)

puts 'starting stream'
stream.sample(language:'en') do |object|

  if object.is_a?(Twitter::Streaming::StallWarning)
    puts "Stall warning"
    next
  end
  next if !object.is_a?(Twitter::Tweet) || object.retweet?

  tweet = Tweet.new(object, rest)
  lyric = lyric_checker.find_matching_lyrics(tweet)
  if lyric
    puts "Tweet:" + tweet.body
    puts "Lyrics: "
    puts lyric.text

    # ----
    # TODO: consider blank lines to be stops in the lyric file
    # ----
    reply_tweet = lyric.next.reduce("") do |string, line|
      new_line = string + "\n" + line

      # TODO: fetch short_url_length_https instead of assuming 24 forever
      if new_line.length > 117 # 140 - 24 for the link + 1 for \n
        break string
      end

      new_line
    end
    reply_tweet.strip! # Remove leading \n
    reply_tweet << ' ' + tweet.url

    puts "Possible reply_tweet (#{reply_tweet.length} chars):"
    puts reply_tweet
    if ENV['SEND_TWEETS'] == 'true'
      update_result = rest.update(reply_tweet)
    end

    puts "---"
  end
end
puts 'done'
