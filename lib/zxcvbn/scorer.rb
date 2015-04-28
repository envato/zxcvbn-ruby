require 'zxcvbn/entropy'
require 'zxcvbn/crack_time'
require 'zxcvbn/score'
require 'zxcvbn/match'

module Zxcvbn
  class Scorer
    def initialize(data)
      @data = data
    end

    attr_reader :data

    include Entropy
    include CrackTime

    def minimum_entropy_match_sequence(password, matches)
      bruteforce_cardinality = bruteforce_cardinality(password) # e.g. 26 for lowercase
      up_to_k = []      # minimum entropy up to k.
      backpointers = [] # for the optimal sequence of matches up to k, holds the final match (match.j == k). null means the sequence ends w/ a brute-force character.
      (0...password.length).each do |k|
        # starting scenario to try and beat: adding a brute-force character to the minimum entropy sequence at k-1.
        previous_k_entropy = k > 0 ? up_to_k[k-1] : 0
        up_to_k[k] = previous_k_entropy + lg(bruteforce_cardinality)
        backpointers[k] = nil
        matches.select do |match|
          match.j == k
        end.each do |match|
          i, j = match.i, match.j
          # see if best entropy up to i-1 + entropy of this match is less than the current minimum at j.
          previous_i_entropy = i > 0 ? up_to_k[i-1] : 0
          candidate_entropy = previous_i_entropy + calc_entropy(match)
          if up_to_k[j] && candidate_entropy < up_to_k[j]
            up_to_k[j] = candidate_entropy
            backpointers[j] = match
          end
        end
      end

      # walk backwards and decode the best sequence
      match_sequence = []
      k = password.length - 1
      while k >= 0
        match = backpointers[k]
        if match
          match_sequence.unshift match
          k = match.i - 1
        else
          k -= 1
        end
      end

      match_sequence = pad_with_bruteforce_matches(match_sequence, password, bruteforce_cardinality)
      score_for(password, match_sequence, up_to_k)
    end

    def score_for password, match_sequence, up_to_k
      min_entropy = up_to_k[password.length - 1] || 0  # or 0 corner case is for an empty password ''
      crack_time = entropy_to_crack_time(min_entropy)

      # final result object
      Score.new(
        :password => password,
        :entropy => min_entropy.round(3),
        :match_sequence => match_sequence,
        :crack_time => crack_time.round(3),
        :crack_time_display => display_time(crack_time),
        :score => crack_time_to_score(crack_time)
      )
    end


    def pad_with_bruteforce_matches(match_sequence, password, bruteforce_cardinality)
      k = 0
      match_sequence_copy = []
      match_sequence.each do |match|
        if match.i > k
          match_sequence_copy << make_bruteforce_match(password, k, match.i - 1, bruteforce_cardinality)
        end
        k = match.j + 1
        match_sequence_copy << match
      end
      if k < password.length
        match_sequence_copy << make_bruteforce_match(password, k, password.length - 1, bruteforce_cardinality)
      end
      match_sequence_copy
    end
    # fill in the blanks between pattern matches with bruteforce "matches"
    # that way the match sequence fully covers the password:
    # match1.j == match2.i - 1 for every adjacent match1, match2.
    def make_bruteforce_match(password, i, j, bruteforce_cardinality)
      Match.new(
        :pattern => 'bruteforce',
        :i => i,
        :j => j,
        :token => password[i..j],
        :entropy => lg(bruteforce_cardinality ** (j - i + 1)),
        :cardinality => bruteforce_cardinality
      )
    end
  end
end
