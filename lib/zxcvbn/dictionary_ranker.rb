# frozen_string_literal: true

require 'zxcvbn/case_helpers'

module Zxcvbn
  # Converts raw word lists into frequency-ranked dictionaries for matcher use.
  # @api private
  class DictionaryRanker
    # Ranks multiple word lists, returning a hash of ranked dictionaries.
    #
    # @param lists [Hash{Symbol => Array<String>}] named word lists
    # @return [Hash{Symbol => Hash{String => Integer}}] lowercased word → rank mappings
    def self.rank_dictionaries(lists)
      lists.transform_values do |words|
        rank_dictionary(words)
      end
    end

    # Ranks a single word list; rank starts at 1 (most common).
    #
    # @param words [Array<String>] ordered words (most common first)
    # @return [Hash{String => Integer}] lowercased word → 1-based rank
    def self.rank_dictionary(words)
      words
        .each_with_index
        .with_object({}) do |(word, i), dictionary|
          dictionary[CaseHelpers.downcase_preserving_length(word)] = i + 1
        end
    end
  end
end
