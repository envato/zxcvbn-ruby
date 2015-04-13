require 'zxcvbn/match'

module Zxcvbn
  module Matchers
    class Sequences
      SEQUENCES = {
        'lower' => 'abcdefghijklmnopqrstuvwxyz',
        'upper' => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'digits' => '01234567890'
      }

      def seq_match_length(password, from, direction, seq)
        index_from = seq.index(password[from])
        j = 1
        while from + j < password.length &&
              password[from + j] == seq[index_from + direction * j]
          j+= 1
        end
        j
      end

      # find the first matching sequence, and return with
      # direction, if characters are one apart in the sequence
      def applicable_sequence(password, i)
        SEQUENCES.each do |name, sequence|
          index1 = sequence.index(password[i])
          index2 = sequence.index(password[i+1])
          if index1 and index2
            seq_direction = index2 - index1
            if [-1, 1].include?(seq_direction)
              return [name, sequence, seq_direction]
            else
              return nil
            end
          end
        end
      end

      def matches(password)
        result = []
        i = 0
        while i < password.length - 1
          seq_name, seq, seq_direction = applicable_sequence(password, i)

          if seq
            length = seq_match_length(password, i, seq_direction, seq)
            if length > 2
              result << Match.new(
                :pattern => 'sequence',
                :i => i,
                :j => i + length - 1,
                :token => password[i, length],
                :sequence_name => seq_name,
                :sequence_space => seq.length,
                :ascending => seq_direction == 1
              )
            end
            i += length - 1
          else
            i += 1
          end
        end
        result
      end
    end
  end
end
