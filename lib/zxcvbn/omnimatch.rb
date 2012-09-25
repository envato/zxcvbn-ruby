module Zxcvbn
  class Omnimatch
    attr_reader :ranked_dictionaries

    def initialize
      @ranked_dictionaries = rank_dictionaries
      @matchers = build_matchers
    end

    def matches(password)
      result = []
      @matchers.each do |matcher|
        result += matcher.matches(password)
      end
      result
    end

    private

    def rank_dictionaries
      dictionaries = {}
      FREQUENCY_LISTS.each do |dict_name, words|
        dictionaries[dict_name] = rank_dictionary(words)
      end
      dictionaries
    end

    def rank_dictionary(words)
      dictionary = {}
      i = 1
      words.each do |word|
        dictionary[word] = i
        i += 1
      end
      dictionary
    end

    def build_matchers
      matchers = []
      dictionary_matchers = @ranked_dictionaries.map do |name, dictionary|
        Matchers::Dictionary.new(name, dictionary)
      end
      l33t_matcher = Matchers::L33t.new(dictionary_matchers)
      matchers += dictionary_matchers
      matchers += [
        l33t_matcher,
        Matchers::Spatial.new(ADJACENCY_GRAPHS),
        Matchers::Digits.new,
        Matchers::Repeat.new,
        Matchers::Sequences.new,
        Matchers::Year.new,
        Matchers::Date.new
      ]
      matchers
    end
  end
end