require 'zxcvbn/match'

module Zxcvbn
  module Matchers
    class Repeat
      def matches(password)
        result = []
        i = 0
        while i < password.length
          cur_char = password[i]
          j = i + 1
          while cur_char == password[j]
            j += 1
          end

          if j - i > 2 # don't consider length 1 or 2 chains.
            result << Match.new(
              :pattern => 'repeat',
              :i => i,
              :j => j-1,
              :token => password[i...j],
              :repeated_char => cur_char
            )
          end

          i = j
        end
        result
      end
    end
  end
end
