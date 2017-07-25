require './line'

class LyricChecker
  MATCH_SCORE_THRESHOLD = ENV['MATCH_SCORE_THRESHOLD']&.to_i
  NEXT_LINES_TO_INCLUDE = 10

  def initialize(corpus)
    @corpus = corpus
  end

  def find_matching_lyrics(tweet)
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

