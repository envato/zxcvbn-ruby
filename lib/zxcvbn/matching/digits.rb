module Zxcvbn
  module Matching
    class Digits
      DIGITS_REGEX = /\d{3,}/

      def matches(password)
        result = []
        re_match_all(password) do |match|
          match.pattern = 'digits'
          result << match
        end
        result
      end

      private

      def re_match_all(password)
        loop do
          match = DIGITS_REGEX.match(password)
          break unless match
          i, j = match.offset(0)
          yield Match.new(
            :i => i,
            :j => j,
            :token => password[i...j]
          )
          password = password.sub(match[0], ' ' * match[0].length)
        end
      end
    end
  end
end