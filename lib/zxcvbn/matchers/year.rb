# frozen_string_literal: true

require 'zxcvbn/matchers/regex_helpers'

module Zxcvbn
  module Matchers
    # Matches 4-digit year substrings (1900–2050) in the password.
    class Year
      include RegexHelpers

      # Matches years from 1900 to 2050.
      YEAR_REGEX = /19\d\d|20[0-4]\d|2050/

      # @param password [String]
      # @return [Array<Match>] matches with pattern "year"
      def matches(password)
        result = []
        re_match_all(YEAR_REGEX, password) do |match|
          match.pattern = 'year'
          result << match
        end
        result
      end
    end
  end
end
