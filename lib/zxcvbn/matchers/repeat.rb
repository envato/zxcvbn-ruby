# frozen_string_literal: true

require 'zxcvbn/match_builder'

module Zxcvbn
  module Matchers
    # Finds repeated substrings in a password (e.g. "abcabc", "aaaa").
    #
    # Uses a greedy/lazy regex disambiguation strategy from zxcvbn.js v4:
    # prefer the greedier match unless the lazy match is longer, then use
    # LAZY_ANCHORED to extract the minimal repeating unit (base_token).
    # @api private
    class Repeat
      # Greedily matches the longest repeated substring.
      GREEDY        = /(.+)\1+/
      # Lazily matches the shortest repeated substring.
      LAZY          = /(.+?)\1+/
      # Anchored lazy pattern used to extract the minimal base token.
      LAZY_ANCHORED = /^(.+?)\1+$/

      # Find all repeated-substring matches in the password.
      #
      # @param password [String] the password to search
      # @return [Array<MatchBuilder>] matches with pattern 'repeat', each containing
      #   base_token (the repeated unit) and repeat_count
      def matches(password)
        result = []
        last_index = 0

        while last_index < password.length
          greedy_match = GREEDY.match(password, last_index)
          lazy_match   = LAZY.match(password, last_index)
          break unless greedy_match

          if greedy_match[0].length > lazy_match[0].length
            rx_match   = greedy_match
            base_token = LAZY_ANCHORED.match(rx_match[0])[1]
          else
            rx_match   = lazy_match
            base_token = rx_match[1]
          end

          i     = rx_match.begin(0)
          j     = rx_match.end(0) - 1
          token = rx_match[0]

          result << MatchBuilder.new(
            pattern: 'repeat',
            i:,
            j:,
            token:,
            base_token:,
            repeat_count: token.length / base_token.length
          )

          last_index = j + 1
        end

        result
      end
    end
  end
end
