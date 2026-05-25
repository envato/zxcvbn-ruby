# frozen_string_literal: true

require 'zxcvbn/matchers/regex_helpers'

module Zxcvbn
  module Matchers
    # Matches runs of 3 or more consecutive digits in the password.
    # @api private
    class Digits
      include RegexHelpers

      # Matches runs of 3 or more consecutive digits.
      DIGITS_REGEX = /\d{3,}/

      # @param password [String]
      # @return [Array<MatchBuilder>] matches with pattern "digits"
      def matches(password)
        result = []
        re_match_all(DIGITS_REGEX, password) do |match|
          match.pattern = 'digits'
          result << match
        end
        result
      end
    end
  end
end
