# frozen_string_literal: true

require 'json'
require 'zxcvbn/dictionary_ranker'
require 'zxcvbn/trie'

module Zxcvbn
  class Data
    def initialize
      @ranked_dictionaries = DictionaryRanker.rank_dictionaries(
        'english' => read_word_list('english.txt'),
        'female_names' => read_word_list('female_names.txt'),
        'male_names' => read_word_list('male_names.txt'),
        'passwords' => read_word_list('passwords.txt'),
        'surnames' => read_word_list('surnames.txt')
      )
      @adjacency_graphs = JSON.parse(DATA_PATH.join('adjacency_graphs.json').read)
      @dictionary_tries = build_tries
    end

    attr_reader :ranked_dictionaries, :adjacency_graphs, :dictionary_tries

    def add_word_list(name, list)
      ranked_dict = DictionaryRanker.rank_dictionary(list)
      @ranked_dictionaries[name] = ranked_dict
      @dictionary_tries[name] = build_trie(ranked_dict)
    end

    private

    def read_word_list(file)
      DATA_PATH.join('frequency_lists', file).read.split
    end

    def build_tries
      @ranked_dictionaries.transform_values { |dict| build_trie(dict) }
    end

    def build_trie(ranked_dictionary)
      trie = Trie.new
      ranked_dictionary.each { |word, rank| trie.insert(word, rank) }
      trie
    end
  end
end
