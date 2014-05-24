module Zxcvbn
  module Matchers
    class Sequences
      SEQUENCES = {
        'lower' => 'abcdefghijklmnopqrstuvwxyz',
        'upper' => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'digits' => '01234567890'
      }

      def matches(password)
        result = []
        i = 0
        while i < password.length - 1
          j = i + 1
          found = false
          SEQUENCES.each do |seq_name, seq|
            next if found
            next unless seq.index(password[i])
            index_i = seq.index(password[i])

            [-1, 1].each do |seq_direction|
              next if found
              next unless seq.index(password[j]) == seq.index(password[i]) + seq_direction
              loop do
                cur_n = password[j] ? seq.index(password[j]) : nil
                if cur_n == index_i + seq_direction * (j - i)
                  j += 1
                else
                  if j - i > 2 # don't consider length 1 or 2 chains.
                    result << Match.new(
                      :pattern => 'sequence',
                      :i => i,
                      :j => j-1,
                      :token => password[i...j],
                      :sequence_name => seq_name,
                      :sequence_space => seq.length,
                      :ascending => seq_direction == 1
                    )
                  end
                  found = true
                  break
                end
              end
            end
          end
          if j > i + 1
            i = j - 1
          else
            i = i + 1
          end
          found = false
        end
        result
      end
    end
  end
end
