# frozen_string_literal: true

require 'zxcvbn/math'

module Zxcvbn
  module Guesses
    include Zxcvbn::Math

    MIN_GUESSES_BEFORE_GROWING_SEQUENCE = 10_000
    MIN_SUBMATCH_GUESSES_SINGLE_CHAR    = 10
    MIN_SUBMATCH_GUESSES_MULTI_CHAR     = 50
    BRUTEFORCE_CARDINALITY              = 10
    MIN_YEAR_SPACE                      = 20

    START_UPPER = /^[A-Z][^A-Z]+$/.freeze
    END_UPPER   = /^[^A-Z]+[A-Z]$/.freeze
    ALL_UPPER   = /^[^a-z]+$/.freeze
    ALL_LOWER   = /^[^A-Z]+$/.freeze

    def estimate_guesses(match, password)
      return match.guesses if match.guesses

      min_guesses = if match.token.length < password.length
        match.token.length == 1 ? MIN_SUBMATCH_GUESSES_SINGLE_CHAR : MIN_SUBMATCH_GUESSES_MULTI_CHAR
      else
        1
      end

      guesses = case match.pattern
      when 'bruteforce' then bruteforce_guesses(match)
      when 'dictionary' then dictionary_guesses(match)
      when 'spatial'    then spatial_guesses(match)
      when 'repeat'     then repeat_guesses(match)
      when 'sequence'   then sequence_guesses(match)
      when 'digits'     then digits_guesses(match)
      when 'year'       then year_guesses(match)
      when 'date'       then date_guesses(match)
      else 1
      end

      match.guesses = [guesses, min_guesses].max
      match.guesses_log10 = ::Math.log10(match.guesses)
      match.guesses
    end

    def bruteforce_guesses(match)
      guesses = BRUTEFORCE_CARDINALITY**match.token.length
      min = match.token.length == 1 ? MIN_SUBMATCH_GUESSES_SINGLE_CHAR + 1 : MIN_SUBMATCH_GUESSES_MULTI_CHAR + 1
      [guesses, min].max
    end

    def repeat_guesses(match)
      match.base_guesses * match.repeat_count
    end

    def sequence_guesses(match)
      first_char = match.token[0]
      base_guesses = if %w[a A z Z 0 1 9].include?(first_char)
        4
      elsif first_char.match?(/\d/)
        10
      else
        26
      end
      base_guesses *= 2 unless match.ascending
      base_guesses * match.token.length
    end

    def digits_guesses(match)
      10**match.token.length
    end

    def year_guesses(match)
      reference_year = Time.now.year
      year_space = [(match.token.to_i - reference_year).abs, MIN_YEAR_SPACE].max
      year_space
    end

    def date_guesses(match)
      reference_year = Time.now.year
      year_space = [(match.year - reference_year).abs, MIN_YEAR_SPACE].max
      guesses = 365 * year_space
      guesses *= 4 if match.separator && !match.separator.empty?
      guesses
    end

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
          guesses += nCk(i - 1, j - 1) * s * d**j
        end
      end

      if match.shifted_count && match.shifted_count > 0
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

    def dictionary_guesses(match)
      match.base_guesses = match.rank
      match.uppercase_variations = uppercase_variations(match)
      match.l33t_variations      = l33t_variations(match)
      reversed_multiplier        = match.reversed ? 2 : 1
      match.base_guesses * match.uppercase_variations * match.l33t_variations * reversed_multiplier
    end

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

    def l33t_variations(match)
      return 1 unless match.l33t

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
  end
end
