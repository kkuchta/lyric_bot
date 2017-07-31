class TweetProcessor
  def initialize(lyric_checker)
    @lyric_checker = lyric_checker

    # If any thread throws an exception, the whole thing dies.
    Thread.abort_on_exception = true
  end

  def run
    [
      Thread.new { run_mention_search },
      Thread.new { run_sample }
    ].map(&:join)
  end

  private

  def run_mention_search
    puts "----- running search"

    # Look at all tweets for my account
    stream_client.user(replies: 'all') do |object|
      if object.is_a?(Twitter::Streaming::Event) && object.name == :quoted_tweet
        puts "found from quoted_tweet" if process_tweet(object.target_object)
      elsif object.is_a?(Twitter::Tweet)
        puts "found from user" if process_tweet(object)
      end
    end
  end

  def run_sample
    puts "------------- running sample"
    stream_client.sample(language: 'en') do |object|
      next
      next unless object.is_a?(Twitter::Tweet)
      puts "found from sample" if process_tweet(object)
    end
  end


  def process_tweet(object)

    # Skip if this is my own tweet
    return if object.user.id == me.id

    return if object.retweet?

    # Skip replies (but allow replies to me)
    return if object.reply? && object.in_reply_to_user_id != me.id

    # Ok, it's some kind of tweet we want to check; let's see if it's a match
    # TODO: remove links and/or mentions at the end of the tweet, probs in line.rb
    tweet = Tweet.new(object, rest_client)
    return unless lyric = @lyric_checker.find_matching_lyrics(tweet)

    puts "Tweet:" + tweet.body
    puts "Lyrics: "
    puts lyric.text

    if object.quote?
      respond_with_quote(tweet, lyric)
    elsif object.reply? || tweet.body.include?(me.screen_name)
      respond_with_reply(tweet, lyric)
    else
      respond_with_quote(tweet, lyric)
    end

    puts "---"
    true
  end

  def respond_with_reply(tweet, lyric)
    puts "responding with reply"
    source_screen_name = '@' + tweet.source_screen_name
    reply_tweet = lyric.next_lines(140 - (source_screen_name.length + 1))
    reply_tweet = source_screen_name + ' ' + reply_tweet

    puts "\nreply_tweet (#{reply_tweet.length} chars):"
    puts reply_tweet

    if ENV['SEND_TWEETS'] == 'true'
      result = rest_client.update(reply_tweet, in_reply_to_status_id: tweet.id)
      puts 'here'
    else
      puts 'Sending disabled'
    end
  end

  def respond_with_quote(tweet, lyric)
    puts "replying with quote"

    # 140 - 24 for the link
    reply_tweet = lyric.next_lines(116)

    reply_tweet << ' ' + tweet.url

    puts "\nreply_tweet (#{reply_tweet.length} chars):"
    puts reply_tweet

    if ENV['SEND_TWEETS'] == 'true'
      update_result = rest_client.update(reply_tweet)
    else
      puts 'Sending disabled'
    end
  end

  def me
    @_me ||= rest_client.user
  end

  #def my_id
    #@_id ||= rest_client.user.id
  #end
  #def my_screen_name
    #@_screen_name ||= rest_client.user.screen_name
  #end

  def stream_client
    @_stream ||= Twitter::Streaming::Client.new do |config|
      config.consumer_key        = ENV['CONSUMER_KEY']
      config.consumer_secret     = ENV['CONSUMER_SECRET']
      config.access_token        = ENV['ACCESS_TOKEN']
      config.access_token_secret = ENV['ACCESS_SECRET']
    end
  end

  def rest_client
    @_rest ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['CONSUMER_KEY']
      config.consumer_secret     = ENV['CONSUMER_SECRET']
      config.access_token        = ENV['ACCESS_TOKEN']
      config.access_token_secret = ENV['ACCESS_SECRET']
    end
  end
end
