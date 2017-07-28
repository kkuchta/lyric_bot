require 'active_support/inflector'

class CommonWords
  WORDLIST_PATH = './common_words.txt'
  class << self

    # Expect the word to already be lowercase and a-z only
    def score(word)
      @_score_cache ||= {}
      return @_score_cache[word] if @_score_cache[word]

      position = find_position(word)

      # The most common word is worth `floor`
      # The least common word is worth `10k * coefficient + floor`
      # Unkown words are word `unkown`
      floor = 2
      coefficient = 0.0006 # max = 8
      unknown = 9
      @_score_cache[word] = position \
        ? position * coefficient + floor
        : unknown
    end

    private

    def find_position(word)
      # TODO: normalize input for contractions
      words.index(word) || words.index(word.singularize)
    end

    def words
      @_words ||=
        File
          .readlines(WORDLIST_PATH)
          .map(&:strip)
    end
  end
end
