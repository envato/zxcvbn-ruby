# frozen_string_literal: true

require 'json'
require 'zxcvbn/dictionary_ranker'
require 'zxcvbn/trie'

module Zxcvbn
  # Holds all loaded frequency lists, adjacency graphs, tries, and graph stats
  # used by the matchers and scorer.
  #
  # @attr_reader adjacency_graphs [Hash{String => Hash}] keyboard adjacency data
  # @attr_reader graph_stats [Hash{String => Hash}] precomputed average degree and key count
  # @attr_reader dictionaries [#ranked, #tries] consistent snapshot of ranked dictionaries and
  #   their tries; use this for concurrent reads to guarantee the pair is always in sync
  # @api private
  class Data
    # Consistent snapshot of ranked dictionaries and their tries.
    # Stored as a single reference so it can be swapped atomically on update.
    Dictionaries = ::Data.define(:ranked, :tries)
    private_constant :Dictionaries

    # Mutex serialising concurrent calls to {#add_word_list}.
    WRITE_MUTEX = Mutex.new
    private_constant :WRITE_MUTEX

    # Loads all built-in frequency lists and adjacency graphs from disk.
    def initialize
      ranked = DictionaryRanker.rank_dictionaries(
        'english_wikipedia' => read_word_list('english_wikipedia.txt'),
        'female_names' => read_word_list('female_names.txt'),
        'male_names' => read_word_list('male_names.txt'),
        'passwords' => read_word_list('passwords.txt'),
        'surnames' => read_word_list('surnames.txt'),
        'us_tv_and_film' => read_word_list('us_tv_and_film.txt')
      )
      @dictionaries = Dictionaries.new(ranked:, tries: build_tries(ranked))
      @adjacency_graphs = JSON.parse(DATA_PATH.join('adjacency_graphs.json').read)
      @graph_stats = compute_graph_stats
    end

    attr_reader :adjacency_graphs, :graph_stats, :dictionaries

    # @return [Hash{String => Hash{String => Integer}}] word → rank maps
    def ranked_dictionaries = @dictionaries.ranked

    # @return [Hash{String => Trie}] prefix tries per dictionary
    def dictionary_tries = @dictionaries.tries

    # Adds a custom word list and builds a trie for it.
    #
    # Safe to call concurrently with {#dictionaries} reads and with other
    # {#add_word_list} calls. The mutex serialises writers; the atomic reference
    # swap ensures readers always observe a consistent ranked/tries pair.
    #
    # @param name [String] dictionary name (used as a key in {#ranked_dictionaries})
    # @param list [Array<String>] ordered words (most common first)
    # @return [void]
    def add_word_list(name, list)
      ranked_dict = DictionaryRanker.rank_dictionary(list)
      trie = Trie.from_ranked(ranked_dict)
      WRITE_MUTEX.synchronize do
        old = @dictionaries
        @dictionaries = Dictionaries.new(
          ranked: old.ranked.merge(name => ranked_dict),
          tries: old.tries.merge(name => trie)
        )
      end
    end

    private

    def read_word_list(file)
      DATA_PATH.join('frequency_lists', file).read.split
    end

    def build_tries(ranked)
      ranked.transform_values { |dict| Trie.from_ranked(dict) }
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
