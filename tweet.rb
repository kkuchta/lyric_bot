class Tweet
  CLEAN_REGEX = /[^a-zA-Z \n]/
  def initialize(tweet_object)
    @tweet_object = tweet_object
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
end
