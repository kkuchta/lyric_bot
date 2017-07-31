class Tweet
  CLEAN_REGEX = /[^a-zA-Z \n]/
  def initialize(tweet_object, client)
    @tweet_object = tweet_object
    @client = client
  end

  def body
    @tweet_object.text
  end

  def tokens
    @_tokens ||= body
      .gsub(CLEAN_REGEX, '')
      .downcase
      .split(/[ \n]/)
      .reject(&:empty?)
      .reject{ |token| token =~ /^http/ } # Remove links
      .reject{ |token| token =~ screen_name_regexp } # Remove mentions of me
  end

  def screen_name_regexp
    @@_regexp ||= Regexp.new('^' + @client.user.screen_name)
  end

  def retweet
    @client.retweet(@tweet_object)
  end

  def id
    @tweet_object.id
  end

  def source_screen_name
    @tweet_object.user.screen_name
  end

  def url
    @tweet_object.uri
  end
end
