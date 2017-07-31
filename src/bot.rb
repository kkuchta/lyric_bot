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
require_relative './tweet_processor'


puts 'initializing corpus'
corpus = File.read('./hamilton_corpus.txt')
lyric_checker = LyricChecker.new(corpus)

tweet_processor = TweetProcessor.new(lyric_checker)
tweet_processor.run

puts "Closing bot"
