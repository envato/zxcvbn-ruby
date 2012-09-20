module Zxcvbn
  module Matching
    class Year
      include RegexHelpers

      YEAR_REGEX = /19\d\d|200\d|201\d/

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