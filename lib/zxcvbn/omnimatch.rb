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
        Matching::Dictionary.new(name, dictionary)
      end
      l33t_matcher = Matching::L33t.new(dictionary_matchers)
      matchers += dictionary_matchers
      matchers += [
        l33t_matcher,
        Matching::Spatial.new(ADJACENCY_GRAPHS),
        Matching::Digits.new,
        Matching::Repeat.new,
        Matching::Sequences.new,
        Matching::Year.new,
        Matching::Date.new
      ]
      matchers
    end
  end
end