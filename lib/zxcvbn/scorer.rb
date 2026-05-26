# frozen_string_literal: true

require 'zxcvbn/guesses'
require 'zxcvbn/crack_time'
require 'zxcvbn/score'
require 'zxcvbn/match_builder'

module Zxcvbn
  # Finds the match sequence that minimises the total number of guesses
  # required to crack a password, using dynamic programming.
  # @api private
  class Scorer
    include Guesses
    include CrackTime

    # Hash{Integer => Float} — factorial lookup for the DP hot loop.
    # Keys must be non-negative integers. Precomputed to 170 (the last value
    # before overflow); returns Float::MAX for any key > 170.
    FACTORIAL = (0..170).each_with_object(Hash.new { Float::MAX }) do |n, h|
      h[n] = n < 2 ? 1.0 : h[n - 1] * n
    end.freeze

    # Hash{Integer => Float} — powers of {MIN_GUESSES_BEFORE_GROWING_SEQUENCE} for the
    # additive sequence-length penalty. Keys must be non-negative integers.
    # Precomputed to 77 (the last value before overflow); returns Float::MAX for
    # any key > 77.
    MIN_GUESSES_POW = (0..77).each_with_object(Hash.new { Float::MAX }) do |n, h|
      h[n] = MIN_GUESSES_BEFORE_GROWING_SEQUENCE.to_f**n
    end.freeze

    private_constant :FACTORIAL, :MIN_GUESSES_POW

    # @param data [Data] the loaded frequency list and graph data
    # @param omnimatch [Omnimatch] shared omnimatch instance
    # @param reference_year [Integer] year used for date/year guess calculations
    def initialize(data, omnimatch, reference_year)
      @data = data
      @omnimatch = omnimatch
      @reference_year = reference_year
      @repeat_cache = {}
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
    # @param matches [Array<MatchBuilder>] candidate matches from the matchers
    # @param exclude_additive [Boolean] omit the sequence-length penalty
    #   (used when recursively analysing repeat base tokens)
    # @return [Score] the optimal score with match sequence and guess count
    def most_guessable_match_sequence(password, matches, exclude_additive: false)
      n = password.length

      return build_score(password, [], 1) if n.zero?

      # index matches by their last character
      matches_by_j = Array.new(n) { [] }
      matches.each { |m| matches_by_j[m.j] << m }
      matches_by_j.each { |arr| arr.sort_by!(&:i) }

      # m[k][l]       = best match for a sequence of l matches ending at position k
      # pi_float[k][l] = cumulative guess product for those l matches as Float (avoids Bignum
      #                  integer multiplication; each step is Integer × Float → Float)
      # g[k][l]        = total guesses (FACTORIAL[l] * pi_float + penalty) as Float
      # g_log10[k][l]  = log10(g[k][l]), used for dominance comparisons (small Float vs Float)
      m        = Array.new(n) { {} }
      pi_float = Array.new(n) { {} }
      g        = Array.new(n) { {} }
      g_log10  = Array.new(n) { {} }

      update = lambda do |match, l|
        j       = match.j
        est     = estimate_guesses(match, password)
        pi_prev = l > 1 ? pi_float[match.i - 1][l - 1] : 1.0
        candidate = FACTORIAL[l] * est * pi_prev
        candidate += MIN_GUESSES_POW[l - 1] unless exclude_additive
        candidate_log10 = ::Math.log10(candidate)
        # only improve if no sequence of length <= l ending at j already beats candidate
        return if g_log10[j].any? { |u, a| u <= l && a <= candidate_log10 }

        g[j][l]         = candidate
        g_log10[j][l]   = candidate_log10
        m[j][l]         = match
        pi_float[j][l]  = est * pi_prev
      end

      make_bruteforce = lambda do |i, j|
        MatchBuilder.new(pattern: 'bruteforce', token: password.slice(i, j - i + 1), i:, j:)
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
      optimal_l = g_log10[n - 1].min_by { |_, v| v }&.first
      total_guesses = optimal_l ? g[n - 1][optimal_l] : 1

      # backtrack to reconstruct sequence
      sequence = []
      k = n - 1
      l = optimal_l
      while k >= 0
        match = m[k][l]
        sequence.unshift(match.build)
        k = match.i - 1
        l -= 1
      end

      build_score(password, sequence, total_guesses)
    end

    # Compute guesses for a repeat match by recursively scoring the base token.
    #
    # @param match [MatchBuilder] a repeat match with base_token set
    # @return [Numeric] base_guesses * repeat_count
    def repeat_guesses(match)
      if match.base_guesses.nil?
        # The same base_token can appear in multiple distinct match objects when
        # a repeated token occurs at several positions in the password. Cache by
        # string so each unique base_token is scored at most once per scoring run.
        match.base_guesses = @repeat_cache[match.base_token] ||= begin
          base_matches = @omnimatch.matches(match.base_token, reference_year: @reference_year)
          most_guessable_match_sequence(match.base_token, base_matches).guesses
        end
      end
      match.base_guesses * match.repeat_count
    end

    private

    # @param password [String]
    # @param sequence [Array<Match>]
    # @param guesses [Float]
    # @return [Score]
    def build_score(password, sequence, guesses)
      attack_times = estimate_attack_times(guesses)
      Score.new(
        password:,
        guesses:,
        sequence:,
        crack_times_seconds: attack_times[:crack_times_seconds],
        crack_times_display: attack_times[:crack_times_display],
        score: guesses_to_score(guesses)
      )
    end
  end
end
