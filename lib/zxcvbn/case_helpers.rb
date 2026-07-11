# frozen_string_literal: true

module Zxcvbn
  # Shared helper for lowercasing strings without changing their length.
  # @api private
  module CaseHelpers
    module_function

    # String#downcase can grow a string — "İ" (U+0130) downcases to "i" plus
    # combining dot above (U+0069 U+0307). Matchers rely on the lowercased
    # password sharing the original's character indices, so a grown string
    # sends out-of-range match positions to the scorer. When lengths diverge,
    # fall back to per-character downcasing, truncating any multi-character
    # mapping to its first character to keep positions aligned 1:1.
    #
    # @param string [String]
    # @return [String] lowercased string with the same character length
    def downcase_preserving_length(string)
      lowercased = string.downcase
      return lowercased if lowercased.length == string.length

      string.each_char.map { |char| char.downcase[0] }.join
    end
  end
end
