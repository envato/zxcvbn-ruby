require 'zxcvbn/dictionary_ranker'
require 'zxcvbn/matchers/dictionary'
require 'zxcvbn/matchers/l33t'
require 'zxcvbn/matchers/spatial'
require 'zxcvbn/matchers/digits'
require 'zxcvbn/matchers/repeat'
require 'zxcvbn/matchers/sequences'
require 'zxcvbn/matchers/year'
require 'zxcvbn/matchers/date'

module Zxcvbn
  class Omnimatch
    def initialize(data)
      @data = data
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
      dictionary_matchers = @data.ranked_dictionaries.map do |name, dictionary|
        Matchers::Dictionary.new(name, dictionary)
      end
      l33t_matcher = Matchers::L33t.new(dictionary_matchers)
      matchers += dictionary_matchers
      matchers += [
        l33t_matcher,
        Matchers::Spatial.new(@data.adjacency_graphs),
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
