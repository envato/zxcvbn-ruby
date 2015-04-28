require 'zxcvbn/match'

module Zxcvbn
  module Matchers
    module RegexHelpers
      def re_match_all(regex, password)
        pos = 0
        while re_match = regex.match(password, pos)
          i, j = re_match.offset(0)
          pos = j
          j -= 1

          match = Match.new(
            :i => i,
            :j => j,
            :token => password[i..j]
          )
          yield match, re_match
        end
      end
    end
  end
end
