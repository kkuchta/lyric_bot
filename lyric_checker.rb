class LyricChecker
  WORD_MATCH_THRESHOLD = 5
  NEXT_LINES_TO_INCLUDE = 5

  # Right now we only check a single song, at least for testing purposes.
  def initialize(corpus)
    @corpus = corpus
  end

  def find_matching_lyrics(tweet)
    return if tweet.tokens.length < WORD_MATCH_THRESHOLD
    lines.each do |line|
      if line.matches(tweet.tokens)
        return line
      end
    end
    return nil
  end

  def lines
    @_lines = @corpus
      .split("\n")
      .each_cons(NEXT_LINES_TO_INCLUDE)
      .map { |line_pair| Line.new(*line_pair) }
  end
end

class Line
  MIN_LINE_LENGTH = 3
  TOKEN_REGEX = /[^a-zA-Z ]/
  def initialize(line_text, *next_lines)
    @line_text = line_text
    @next_lines = next_lines
  end

  def tokens
    @_tokens ||= @line_text
      .gsub(TOKEN_REGEX, '')
      .downcase
      .split(' ')
  end

  def text
    @line_text
  end

  def next
    @next_lines
  end

  def matches(tweet_tokens)
    # This line is too short (eg "Yes!" or "What?")
    return false if tokens.length < MIN_LINE_LENGTH

    # If this tweet is kinda short _and_ it's shorter than the whole line, skip it
    if tweet_tokens.length < LyricChecker::WORD_MATCH_THRESHOLD && tweet_tokens.length < tokens.length
      return false
    end

    words_to_check = [LyricChecker::WORD_MATCH_THRESHOLD, tweet_tokens.length].min

    words_to_check.times do |i|
      tweet_token = tweet_tokens[tweet_tokens.length - (i+1)]
      line_token = tokens[tokens.length - (i+1)]
      return false if tweet_token != line_token
    end
    return true
  end
end
