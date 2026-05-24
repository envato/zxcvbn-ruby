# frozen_string_literal: true

require 'json'
require 'zxcvbn/dictionary_ranker'
require 'zxcvbn/trie'

module Zxcvbn
  # Holds all loaded frequency lists, adjacency graphs, tries, and graph stats
  # used by the matchers and scorer.
  #
  # @attr_reader ranked_dictionaries [Hash{String => Hash{String => Integer}}] word → rank maps
  # @attr_reader adjacency_graphs [Hash{String => Hash}] keyboard adjacency data
  # @attr_reader dictionary_tries [Hash{String => Trie}] prefix tries per dictionary
  # @attr_reader graph_stats [Hash{String => Hash}] precomputed average degree and key count
  class Data
    # Loads all built-in frequency lists and adjacency graphs from disk.
    def initialize
      @ranked_dictionaries = DictionaryRanker.rank_dictionaries(
        'english' => read_word_list('english.txt'),
        'female_names' => read_word_list('female_names.txt'),
        'male_names' => read_word_list('male_names.txt'),
        'passwords' => read_word_list('passwords.txt'),
        'surnames' => read_word_list('surnames.txt'),
        'us_tv_and_film' => read_word_list('us_tv_and_film.txt')
      )
      @adjacency_graphs = JSON.parse(DATA_PATH.join('adjacency_graphs.json').read)
      @dictionary_tries = build_tries
      @graph_stats = compute_graph_stats
    end

    attr_reader :ranked_dictionaries, :adjacency_graphs, :dictionary_tries, :graph_stats

    # Adds a custom word list and builds a trie for it.
    #
    # @param name [String] dictionary name (used as a key in {#ranked_dictionaries})
    # @param list [Array<String>] ordered words (most common first)
    # @return [void]
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

    def compute_graph_stats
      stats = {}
      @adjacency_graphs.each do |graph_name, graph|
        degrees = graph.map { |_, neighbors| neighbors.compact.size }
        sum = degrees.inject(0, :+)
        average_degree = sum.to_f / graph.size
        starting_positions = graph.length

        stats[graph_name] = {
          average_degree:,
          starting_positions:
        }
      end
      stats
    end
  end
end
