require './line'

class LyricChecker
  MATCH_SCORE_THRESHOLD = 13
  NEXT_LINES_TO_INCLUDE = 5

  # Right now we only check a single song, at least for testing purposes.
  def initialize(corpus)
    @corpus = corpus
  end

  def find_matching_lyrics(tweet)
    #return if tweet.tokens.length < WORD_MATCH_THRESHOLD
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

  def least_common_words
    binding.pry
  end
end

