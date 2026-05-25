# frozen_string_literal: true

require 'zxcvbn/match_builder'

module Zxcvbn
  # Namespace for all password pattern matchers.
  module Matchers
    # Shared helper for iterating non-overlapping regex matches over a password.
    module RegexHelpers
      # Yields a {Match} and the underlying MatchData for every non-overlapping
      # occurrence of regex in password.
      #
      # @param regex [Regexp] pattern to search for
      # @param password [String] the password to search
      # @yieldparam match [Match] match with i, j, and token set
      # @yieldparam re_match [MatchData] the underlying MatchData object
      # @return [void]
      def re_match_all(regex, password)
        pos = 0
        while (re_match = regex.match(password, pos))
          i, j = re_match.offset(0)
          pos = j
          j -= 1

          match = MatchBuilder.new(i:, j:, token: password.slice(i, j - i + 1))
          yield match, re_match
        end
      end
    end
  end
end
