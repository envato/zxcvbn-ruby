# frozen_string_literal: true

require 'zxcvbn/guesses'
require 'zxcvbn/crack_time'
require 'zxcvbn/score'
require 'zxcvbn/match'

module Zxcvbn
  # Finds the match sequence that minimises the total number of guesses
  # required to crack a password, using dynamic programming.
  class Scorer
    include Guesses
    include CrackTime

    # @param data [Data] the loaded frequency list and graph data
    def initialize(data)
      @data = data
    end

    attr_reader :data

    # Find the match sequence that minimises total guesses for a password.
    #
    # Uses a DP over positions in the password. At each position k and sequence
    # length l, the total cost is:
    #   factorial(l) * product_of_guesses + MIN_GUESSES^(l-1)
    #
    # The additive penalty discourages padding attacks where an adversary
    # splits a password into many low-guesses submatches.
    #
    # @param password [String] the password to analyse
    # @param matches [Array<Match>] candidate matches from the matchers
    # @param exclude_additive [Boolean] omit the sequence-length penalty
    #   (used when recursively analysing repeat base tokens)
    # @return [Score] the optimal score with match sequence and guess count
    def most_guessable_match_sequence(password, matches, exclude_additive: false, user_inputs: [])
      n = password.length

      return build_score(password, [], 1) if n.zero?

      # index matches by their last character
      matches_by_j = Array.new(n) { [] }
      matches.each { |m| matches_by_j[m.j] << m }
      matches_by_j.each { |arr| arr.sort_by!(&:i) }

      # m[k][l] = best match for a sequence of l matches ending at position k
      # pi[k][l] = cumulative product of guesses for those l matches
      # g[k][l]  = total guesses (factorial(l) * pi + penalty)
      m  = Array.new(n) { {} }
      pi = Array.new(n) { {} }
      g  = Array.new(n) { {} }

      update = lambda do |match, l|
        j   = match.j
        est = estimate_guesses(match, password, user_inputs: user_inputs)
        est *= pi[match.i - 1][l - 1] if l > 1
        candidate = factorial(l) * est
        candidate += MIN_GUESSES_BEFORE_GROWING_SEQUENCE.to_f**(l - 1) unless exclude_additive
        # only improve if no sequence of length <= l ending at j already beats candidate
        return if g[j].any? { |u, a| u <= l && a <= candidate }

        g[j][l]  = candidate
        m[j][l]  = match
        pi[j][l] = est
      end

      make_bruteforce = lambda do |i, j|
        Match.new(pattern: 'bruteforce', token: password.slice(i, j - i + 1), i: i, j: j)
      end

      (0...n).each do |k|
        matches_by_j[k].each do |match|
          if match.i.positive?
            m[match.i - 1].each_key { |l| update.call(match, l + 1) }
          else
            update.call(match, 1)
          end
        end

        # try bruteforce segments ending at k
        update.call(make_bruteforce.call(0, k), 1)
        (1..k).each do |t|
          bf = make_bruteforce.call(t, k)
          m[t - 1].each do |l, prev_match|
            update.call(bf, l + 1) unless prev_match.pattern == 'bruteforce'
          end
        end
      end

      # find sequence length with minimum guesses at position n-1
      optimal_l = g[n - 1].min_by { |_, v| v }&.first
      total_guesses = optimal_l ? g[n - 1][optimal_l] : 1

      # backtrack to reconstruct sequence
      sequence = []
      k = n - 1
      l = optimal_l
      while k >= 0
        match = m[k][l]
        sequence.unshift(match)
        k = match.i - 1
        l -= 1
      end

      build_score(password, sequence, total_guesses)
    end

    # Compute guesses for a repeat match by recursively scoring the base token.
    #
    # Lazily instantiates an {Omnimatch} when first needed.
    #
    # @param match [Match] a repeat match with base_token set
    # @param user_inputs [Array] caller-supplied words passed through to sub-scoring
    # @return [Integer] base_guesses * repeat_count
    def repeat_guesses(match, user_inputs: [])
      if match.base_guesses.nil?
        require 'zxcvbn/omnimatch'
        @omnimatch ||= Omnimatch.new(@data)
        base_matches  = @omnimatch.matches(match.base_token, user_inputs)
        base_analysis = most_guessable_match_sequence(match.base_token, base_matches,
                                                      user_inputs: user_inputs)
        match.base_guesses = base_analysis.guesses
      end
      match.base_guesses * match.repeat_count
    end

    private

    # @param password [String]
    # @param sequence [Array<Match>]
    # @param guesses [Integer]
    # @return [Score]
    def build_score(password, sequence, guesses)
      entropy    = ::Math.log2([guesses, 1].max)
      crack_time = entropy_to_crack_time(entropy)
      Score.new(
        password: password,
        guesses: guesses,
        entropy: entropy.round(3),
        match_sequence: sequence,
        crack_time: crack_time.round(3),
        crack_time_display: display_time(crack_time),
        score: guesses_to_score(guesses)
      )
    end

    def factorial(n)
      return 1 if n < 2

      (2..n).reduce(1.0, :*)
    end
  end
end
