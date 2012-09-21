module Zxcvbn
  module Matching
    module RegexHelpers
      def re_match_all(regex, password)
        loop do
          re_match = regex.match(password)
          break unless re_match
          i, j = re_match.offset(0)
          match = Match.new(
            :i => i,
            :j => j,
            :token => password[i...j]
          )
          yield match, re_match
          password = password.sub(re_match[0], ' ' * re_match[0].length)
        end
      end
    end
  end
end