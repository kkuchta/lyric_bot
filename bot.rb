require 'dotenv'
require 'twitter'

Dotenv.load

if ENV['ENV'] == 'development'
  require 'pry-byebug'
end

require './lyric_checker'
require './tweet'

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_SECRET']
end

corpus = File.read('hamilton_corpus.txt')

lyric_checker = LyricChecker.new(corpus)

puts 'starting'
client.sample(language:'en') do |object|

  if object.is_a?(Twitter::Streaming::StallWarning)
    puts "Stall warning"
    next
  end
  next if !object.is_a?(Twitter::Tweet) || object.retweet?

  tweet = Tweet.new(object)
  lyric = lyric_checker.find_matching_lyrics(tweet)
  if lyric
    puts "Tweet:" + tweet.body
    puts "Lyrics: "
    puts lyric.text
    puts lyric.next.join("\n")
    puts "---"
  end
end
puts 'done'
