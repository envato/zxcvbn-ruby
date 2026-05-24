# frozen_string_literal: true

require 'zxcvbn/matchers/regex_helpers'

module Zxcvbn
  module Matchers
    class Year
      include RegexHelpers

      YEAR_REGEX = /19\d\d|20[0-4]\d|2050/

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
