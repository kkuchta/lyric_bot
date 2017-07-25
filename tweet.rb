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
  end

  def retweet
    @client.retweet(@tweet_object)
  end
end
