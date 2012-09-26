require 'json'

module Zxcvbn
  class Omnimatch
    DATA_PATH = Pathname(File.expand_path('../../../data', __FILE__))
    ADJACENCY_GRAPHS = JSON.load(DATA_PATH.join('adjacency_graphs.json').read)
    FREQUENCY_LISTS = YAML.load(DATA_PATH.join('frequency_lists.yaml').read)

    attr_reader :ranked_dictionaries

    def initialize
      @ranked_dictionaries = rank_dictionaries
      @matchers = build_matchers
    end

    def matches(password, user_inputs = [])
      result = []
      (@matchers + user_input_matchers(user_inputs)).each do |matcher|
        result += matcher.matches(password)
      end
      result
    end

    private

    def user_input_matchers(user_inputs)
      return [] unless user_inputs.any?
      user_ranked_dictionary = rank_dictionary(user_inputs)
      dictionary_matcher = Matchers::Dictionary.new('user_inputs', user_ranked_dictionary)
      l33t_matcher = Matchers::L33t.new([dictionary_matcher])
      [dictionary_matcher, l33t_matcher]
    end

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