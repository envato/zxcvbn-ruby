module Zxcvbn
  module Matching
    class Sequences
      SEQUENCES = {
        'lower' => 'abcdefghijklmnopqrstuvwxyz',
        'upper' => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'digits' => '01234567890'
      }

      def matches(password)
        result = []
        i = 0
        while i < password.length-1
          j = i + 1
          seq = nil # either lower, upper, or digits
          seq_name = nil
          seq_direction = nil # 1 for ascending seq abcd, -1 for dcba
          SEQUENCES.each do |seq_candidate_name, seq_candidate|
            seq = nil

            i_n, j_n = [password[i], password[j]].map do |chr|
              chr ? seq_candidate.index(chr) : nil
            end

            if i_n && j_n && i_n > -1 && j_n > -1
              direction = j_n - i_n
              if [1, -1].include?(direction)
                seq = seq_candidate
                seq_name = seq_candidate_name
                seq_direction = direction
              end
            end
            if seq
              loop do
                prev_char, cur_char = password[(j-1)], password[j]
                prev_n, cur_n = [prev_char, cur_char].map do |chr|
                  chr ? seq_candidate.index(chr) : nil
                end
                if prev_n && cur_n && cur_n - prev_n == seq_direction
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
                  break
                end
              end
            end
          end
          i = j
        end
        result
      end
    end
  end
end