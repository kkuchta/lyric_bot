require './common_words'
class Line
  #MIN_LINE_LENGTH = 3
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
    match_score = 0
    match_scores = {}
    1.step do |i|

      # We want to iterate backwards over each list, starting from the end.
      # 1.step starts at 1.
      tweet_token = tweet_tokens[i * -1]
      line_token = tokens[i * -1]

      # If we got to the end of the tweet (or the end of the line) and didn't
      # hit our match threshold, no match.
      return false if tweet_token == nil || line_token == nil

      if tweet_token == line_token
        score = CommonWords.score(line_token)
        match_score += score
        match_scores[line_token] = score
        if match_score >= LyricChecker::MATCH_SCORE_THRESHOLD
          puts "match score: #{match_score} (#{match_scores}"
          return true
        end
      else
        # If we found a word that doesn't match, the string of matches is broken
        # and we can just return false.
        return false
      end
    end
  end
end
