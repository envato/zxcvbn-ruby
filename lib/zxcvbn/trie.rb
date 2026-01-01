# frozen_string_literal: true

module Zxcvbn
  # A trie (prefix tree) data structure for efficient dictionary matching.
  # Provides fast prefix-based lookups to eliminate unnecessary substring checks.
  #
  # @see https://en.wikipedia.org/wiki/Trie
  class Trie
    def initialize
      @root = {}
    end

    # Insert a word and its rank into the trie
    # @param word [String] the word to insert
    # @param rank [Integer] the rank/frequency of the word
    def insert(word, rank)
      node = @root
      word.each_char do |char|
        node[char] ||= {}
        node = node[char]
      end
      node[:rank] = rank
    end

    # Search for all words in the text starting from a given position
    # @param text [String] the text to search in
    # @param start_pos [Integer] the starting position
    # @return [Array<Array>] array of [word, rank, start, end] tuples
    def search_prefixes(text, start_pos)
      results = []
      node = @root

      (start_pos...text.length).each do |i|
        char = text[i]
        break unless node[char]

        node = node[char]
        results << [text[start_pos..i], node[:rank], start_pos, i] if node[:rank]
      end

      results
    end
  end
end
