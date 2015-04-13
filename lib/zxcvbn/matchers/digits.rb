require 'zxcvbn/matchers/regex_helpers'

module Zxcvbn
  module Matchers
    class Digits
      include RegexHelpers

      DIGITS_REGEX = /\d{3,}/

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
