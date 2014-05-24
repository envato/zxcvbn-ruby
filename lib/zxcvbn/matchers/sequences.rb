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
          SEQUENCES.each do |seq_name, seq|
            next unless seq.index(password[i])
            next unless seq.index(password[j])
            index_i = seq.index(password[i])
            seq_direction = seq.index(password[j]) - seq.index(password[i])
            next unless [-1, 1].include? seq_direction

            while j < password.length &&
                  seq.index(password[j]) == index_i + seq_direction * (j - i)
              j+= 1
            end
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
          end
          i = [i + 1, j - 1].max
        end
        result
      end
    end
  end
end
