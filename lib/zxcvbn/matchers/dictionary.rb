# frozen_string_literal: true

require 'zxcvbn/match'

module Zxcvbn
  module Matchers
    # Matches any sequential segment of the lowercased password that appears in
    # a ranked dictionary.
    class Dictionary
      # @param name [String] dictionary identifier used in match results
      # @param ranked_dictionary [Hash{String => Integer}] lowercased word → rank
      # @param trie [Trie, nil] optional prefix trie for faster lookups
      def initialize(name, ranked_dictionary, trie = nil)
        @name = name
        @ranked_dictionary = ranked_dictionary
        @trie = trie
      end

      # Returns all dictionary matches found in password.
      #
      # @param password [String]
      # @return [Array<Match>] matches with pattern "dictionary"
      def matches(password)
        lowercased_password = password.downcase

        if @trie
          trie_matches(password, lowercased_password)
        else
          hash_matches(password, lowercased_password)
        end
      end

      private

      def trie_matches(password, lowercased_password)
        results = []

        (0...password.length).each do |i|
          @trie.search_prefixes(lowercased_password, i).each do |word, rank, start, ending|
            results << build_match(word, password.slice(start, ending - start + 1), start, ending, rank)
          end
        end

        results
      end

      def hash_matches(password, lowercased_password)
        results = []
        password_length = password.length

        (0..password_length).each do |i|
          (i...password_length).each do |j|
            length = j - i + 1
            word = lowercased_password.slice(i, length)
            next unless @ranked_dictionary.key?(word)

            results << build_match(word, password.slice(i, length), i, j, @ranked_dictionary[word])
          end
        end

        results
      end

      def build_match(matched_word, token, start_pos, end_pos, rank)
        Match.new(
          matched_word:,
          token:,
          i: start_pos,
          j: end_pos,
          rank:,
          pattern: 'dictionary',
          dictionary_name: @name
        )
      end
    end
  end
end
