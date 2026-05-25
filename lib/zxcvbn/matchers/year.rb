# frozen_string_literal: true

require 'zxcvbn/matchers/regex_helpers'

module Zxcvbn
  module Matchers
    # Matches 4-digit year substrings (1900–2019) in the password.
    class Year
      include RegexHelpers

      # Matches years from 1900 to 2019, matching zxcvbn.js v4.
      YEAR_REGEX = /19\d\d|200\d|201\d/

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
