$stdout.sync = true
puts 'Booting up'

require 'dotenv'
require 'twitter'

Dotenv.load

if ENV['ENV'] == 'development'
  require 'pry-byebug'
end

require './lyric_checker'
require './tweet'

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
corpus = File.read('hamilton_corpus.txt')
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
      if new_line.length > 140
        break string
      end

      new_line
    end
    reply_tweet.strip!

    puts "Possible reply_tweet (#{reply_tweet.length} chars):"
    puts reply_tweet
    tweet.retweet
    rest.update(reply_tweet)
    puts "---"
  end
end
puts 'done'
