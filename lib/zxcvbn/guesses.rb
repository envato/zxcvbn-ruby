# frozen_string_literal: true

require 'zxcvbn/math'

module Zxcvbn
  # Mixin that provides guesses estimation for each match pattern.
  #
  # Each pattern-specific method returns a raw guess count; {estimate_guesses}
  # applies a per-token minimum and memoises the result on the match object.
  # Mirrors the guesses estimation logic from zxcvbn.js v4.
  # @api private
  module Guesses
    include Zxcvbn::Math

    MIN_GUESSES_BEFORE_GROWING_SEQUENCE = 10_000
    MIN_SUBMATCH_GUESSES_SINGLE_CHAR    = 10
    MIN_SUBMATCH_GUESSES_MULTI_CHAR     = 50
    BRUTEFORCE_CARDINALITY              = 10
    MIN_YEAR_SPACE                      = 20

    START_UPPER = /^[A-Z][^A-Z]+$/
    END_UPPER   = /^[^A-Z]+[A-Z]$/
    ALL_UPPER   = /^[^a-z]+$/
    ALL_LOWER   = /^[^A-Z]+$/

    # Estimate the number of guesses required to crack a match.
    #
    # Mutates the builder in place: sets guesses, guesses_log10, and any
    # pattern-specific fields (base_guesses, uppercase_variations, l33t_variations).
    # Returns immediately if guesses are already set.
    #
    # @param match [MatchBuilder] the builder to estimate
    # @param password [String] the full password being evaluated
    # @return [Numeric] the estimated guess count
    def estimate_guesses(match, password)
      return match.guesses if match.guesses

      min_guesses =
        if match.token.length < password.length
          match.token.length == 1 ? MIN_SUBMATCH_GUESSES_SINGLE_CHAR : MIN_SUBMATCH_GUESSES_MULTI_CHAR
        else
          1
        end

      guesses =
        case match.pattern
        in 'bruteforce' then bruteforce_guesses(match)
        in 'dictionary' then dictionary_guesses(match)
        in 'spatial'    then spatial_guesses(match)
        in 'repeat'     then repeat_guesses(match)
        in 'sequence'   then sequence_guesses(match)
        in 'digits'     then digits_guesses(match)
        in 'year'       then year_guesses(match)
        in 'date'       then date_guesses(match)
        else 1
        end

      match.guesses = [guesses, min_guesses].max
      match.guesses_log10 = ::Math.log10(match.guesses)
      match.guesses
    end

    # @param match [MatchBuilder] a bruteforce match
    # @return [Numeric] guesses based on token length and assumed cardinality
    def bruteforce_guesses(match)
      guesses = BRUTEFORCE_CARDINALITY**match.token.length.to_f
      guesses = Float::MAX if guesses.infinite?
      min = match.token.length == 1 ? MIN_SUBMATCH_GUESSES_SINGLE_CHAR + 1.0 : MIN_SUBMATCH_GUESSES_MULTI_CHAR + 1.0
      [guesses, min].max
    end

    # @param match [MatchBuilder] a sequence match (e.g. "abc", "6543")
    # @return [Integer] guesses based on sequence type and direction
    def sequence_guesses(match)
      first_char = match.token[0]
      base_guesses =
        if %w[a A z Z 0 1 9].include?(first_char)
          4
        elsif first_char.match?(/\d/)
          10
        else
          26
        end
      base_guesses *= 2 unless match.ascending
      base_guesses * match.token.length
    end

    # @param match [MatchBuilder] a digits match
    # @return [Integer] 10^length (all possible digit strings of that length)
    def digits_guesses(match)
      10**match.token.length
    end

    # @param match [MatchBuilder] a year match
    # @return [Integer] distance from the current year, floored at {MIN_YEAR_SPACE}
    def year_guesses(match)
      [(match.token.to_i - reference_year).abs, MIN_YEAR_SPACE].max
    end

    # @param match [MatchBuilder] a date match with year and separator set
    # @return [Integer] 365 * year_space, multiplied by 4 if a separator is present
    def date_guesses(match)
      year_space = [(match.year - reference_year).abs, MIN_YEAR_SPACE].max
      guesses = 365 * year_space
      guesses *= 4 if match.separator && !match.separator.empty?
      guesses
    end

    # @param match [MatchBuilder] a spatial (keyboard pattern) match
    # @return [Numeric] guesses based on graph topology, turns, and shifted keys
    def spatial_guesses(match)
      if %w[qwerty dvorak].include?(match.graph)
        s = starting_positions_for_graph('qwerty')
        d = average_degree_for_graph('qwerty')
      else
        s = starting_positions_for_graph('keypad')
        d = average_degree_for_graph('keypad')
      end

      guesses = 0
      token_length = match.token.length
      turns = match.turns
      (2..token_length).each do |i|
        possible_turns = [turns, i - 1].min
        (1..possible_turns).each do |j|
          guesses += nCk(i - 1, j - 1) * s * (d**j)
        end
      end

      if match.shifted_count&.positive?
        shifted   = match.shifted_count
        unshifted = token_length - match.shifted_count
        if shifted.zero? || unshifted.zero?
          guesses *= 2
        else
          shift_variations = 0
          (1..[shifted, unshifted].min).each { |i| shift_variations += nCk(shifted + unshifted, i) }
          guesses *= shift_variations
        end
      end

      guesses
    end

    # @param match [MatchBuilder] a dictionary match
    # @return [Integer] rank multiplied by uppercase and l33t variation counts,
    #   plus a factor of 2 if the word was matched in reverse
    def dictionary_guesses(match)
      match.base_guesses = match.rank
      match.uppercase_variations = uppercase_variations(match)
      match.l33t_variations      = l33t_variations(match)
      reversed_multiplier        = match.reversed ? 2 : 1
      match.base_guesses * match.uppercase_variations * match.l33t_variations * reversed_multiplier
    end

    # Count the number of ways the token's capitalisation could have been chosen.
    #
    # Returns 1 for all-lowercase or already-lowercase words. Returns 2 for
    # simple patterns (StartUpper, endUPPER, ALLCAPS). Otherwise returns the
    # sum of combinations for mixed-case tokens.
    #
    # @param match [MatchBuilder] a dictionary match
    # @return [Integer] uppercase variation multiplier
    def uppercase_variations(match)
      word = match.token
      return 1 if word.match?(ALL_LOWER) || word.downcase == word

      [START_UPPER, END_UPPER, ALL_UPPER].each { |r| return 2 if word.match?(r) }

      num_upper = word.chars.count { |c| c.match?(/[A-Z]/) }
      num_lower = word.chars.count { |c| c.match?(/[a-z]/) }
      variations = 0
      (1..[num_upper, num_lower].min).each { |i| variations += nCk(num_upper + num_lower, i) }
      variations
    end

    # Count the number of ways the token's l33t substitutions could have been chosen.
    #
    # Returns 1 if the match has no l33t substitutions. Otherwise multiplies
    # the variation count for each substituted character pair using combinations.
    #
    # @param match [MatchBuilder] a dictionary match, possibly with l33t substitutions
    # @return [Integer] l33t variation multiplier
    def l33t_variations(match)
      return 1 unless match.l33t && match.sub

      variations = 1
      match.sub.each do |subbed, unsubbed|
        chars        = match.token.downcase.chars
        num_subbed   = chars.count { |c| c == subbed }
        num_unsubbed = chars.count { |c| c == unsubbed }
        if num_subbed.zero? || num_unsubbed.zero?
          variations *= 2
        else
          p = [num_subbed, num_unsubbed].min
          sub_variations = 0
          (1..p).each { |i| sub_variations += nCk(num_subbed + num_unsubbed, i) }
          variations *= sub_variations
        end
      end
      variations
    end

    attr_reader :reference_year
  end
end
