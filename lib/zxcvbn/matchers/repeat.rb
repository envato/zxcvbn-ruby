module Zxcvbn
  module Matchers
    class Repeat
      def matches(password)
        result = []
        i = 0
        while i < password.length
          j = i + 1
          loop do
            prev_char, cur_char = password[j-1..j]
            if password[j-1] == password[j]
              j += 1
            else
              if j - i > 2 # don't consider length 1 or 2 chains.
                result << Match.new(
                  :pattern => 'repeat',
                  :i => i,
                  :j => j-1,
                  :token => password[i...j],
                  :repeated_char => password[i]
                )
              end
              break
            end
          end
          i = j
        end
        result
      end
    end
  end
end