require 'json'
require 'yaml'
require 'pathname'

module Zxcvbn
  class Omnimatch
    def initialize
      @matchers = build_matchers
    end

    def matches(password, user_inputs = [])
      matchers = @matchers + user_input_matchers(user_inputs)
      matchers.map do |matcher|
        matcher.matches(password)
      end.inject(&:+)
    end

    private

    def user_input_matchers(user_inputs)
      return [] unless user_inputs.any?
      user_ranked_dictionary = DictionaryRanker.rank_dictionary(user_inputs)
      dictionary_matcher = Matchers::Dictionary.new('user_inputs', user_ranked_dictionary)
      l33t_matcher = Matchers::L33t.new([dictionary_matcher])
      [dictionary_matcher, l33t_matcher]
    end


    def build_matchers
      matchers = []
      dictionary_matchers = RANKED_DICTIONARIES.map do |name, dictionary|
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
