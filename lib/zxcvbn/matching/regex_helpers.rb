module Zxcvbn
  module Matching
    module RegexHelpers
      def re_match_all(regex, password)
        loop do
          match = regex.match(password)
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