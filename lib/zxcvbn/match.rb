# frozen_string_literal: true

module Zxcvbn
  # A substring match found by one of the pattern matchers.
  #
  # All attributes are optional and default to +nil+. Use {#with} to derive a
  # new match with changed attributes.
  #
  # @!attribute [r] pattern
  #   @return [String, nil] the matcher that produced this match
  # @!attribute [r] i
  #   @return [Integer, nil] start index in the password (inclusive)
  # @!attribute [r] j
  #   @return [Integer, nil] end index in the password (inclusive)
  # @!attribute [r] token
  #   @return [String, nil] the matched substring
  # @!attribute [r] matched_word
  #   @return [String, nil] lowercased dictionary word (dictionary matches)
  # @!attribute [r] rank
  #   @return [Integer, nil] frequency rank of the matched word (dictionary matches)
  # @!attribute [r] dictionary_name
  #   @return [String, nil] source dictionary name (dictionary matches)
  # @!attribute [r] reversed
  #   @return [Boolean, nil] true when matched in the reversed password
  # @!attribute [r] l33t
  #   @return [Boolean, nil] true when the match required l33t substitution
  # @!attribute [r] sub
  #   @return [Hash, nil] map of l33t characters to their substituted letters
  # @!attribute [r] sub_display
  #   @return [String, nil] human-readable substitution summary
  # @!attribute [r] guesses
  #   @return [Numeric, nil] estimated guess count
  # @!attribute [r] guesses_log10
  #   @return [Float, nil] log10 of {#guesses}
  # @!attribute [r] base_guesses
  #   @return [Numeric, nil] guesses for the base token (repeat matches) or
  #     rank before variation multipliers (dictionary matches)
  # @!attribute [r] uppercase_variations
  #   @return [Numeric, nil] capitalisation variant count (dictionary matches)
  # @!attribute [r] l33t_variations
  #   @return [Numeric, nil] l33t substitution variant count (dictionary matches)
  # @!attribute [r] base_token
  #   @return [String, nil] the minimal repeating unit (repeat matches)
  # @!attribute [r] repeat_count
  #   @return [Integer, nil] number of repetitions (repeat matches)
  # @!attribute [r] sequence_name
  #   @return [String, nil] sequence type: "lower", "upper", "digits", or "unicode"
  # @!attribute [r] sequence_space
  #   @return [Integer, nil] size of the character set for the sequence
  # @!attribute [r] ascending
  #   @return [Boolean, nil] true if the sequence is ascending
  # @!attribute [r] graph
  #   @return [String, nil] keyboard graph name (spatial matches)
  # @!attribute [r] turns
  #   @return [Integer, nil] number of direction changes (spatial matches)
  # @!attribute [r] shifted_count
  #   @return [Integer, nil] number of shifted characters (spatial matches)
  # @!attribute [r] year
  #   @return [Integer, nil] matched year (date/year matches)
  # @!attribute [r] month
  #   @return [Integer, nil] matched month (date matches)
  # @!attribute [r] day
  #   @return [Integer, nil] matched day (date matches)
  # @!attribute [r] separator
  #   @return [String, nil] date separator character (date matches)
  Match = ::Data.define(
    :pattern, :i, :j, :token, :matched_word, :rank, :dictionary_name, :reversed,
    :l33t, :sub, :sub_display, :guesses, :guesses_log10, :base_guesses,
    :uppercase_variations, :l33t_variations, :base_token, :repeat_count,
    :sequence_name, :sequence_space, :ascending, :graph, :turns, :shifted_count,
    :year, :month, :day, :separator
  ) do
    def initialize(
      pattern: nil, i: nil, j: nil, token: nil, matched_word: nil, rank: nil,
      dictionary_name: nil, reversed: nil, l33t: nil, sub: nil,
      sub_display: nil, guesses: nil, guesses_log10: nil, base_guesses: nil,
      uppercase_variations: nil, l33t_variations: nil, base_token: nil,
      repeat_count: nil, sequence_name: nil, sequence_space: nil,
      ascending: nil, graph: nil, turns: nil, shifted_count: nil,
      year: nil, month: nil, day: nil, separator: nil
    )
      super
    end
  end
end
