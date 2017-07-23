require 'dotenv'
require 'twitter'

Dotenv.load

if ENV['ENV'] == 'development'
  require 'pry-byebug'
end

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_SECRET']
end

client.sample do |object|
  puts object.text if object.is_a?(Twitter::Tweet)
end
puts 'done'
