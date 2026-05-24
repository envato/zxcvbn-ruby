# frozen_string_literal: true

module Zxcvbn
  # A substring match found by one of the pattern matchers.
  #
  # Attributes are set dynamically via {#initialize}; only the attributes
  # relevant to the matched pattern will be populated.
  #
  # @!attribute [rw] pattern
  #   @return [String] the matcher that produced this match
  # @!attribute [rw] i
  #   @return [Integer] start index in the password (inclusive)
  # @!attribute [rw] j
  #   @return [Integer] end index in the password (inclusive)
  # @!attribute [rw] token
  #   @return [String] the matched substring
  # @!attribute [rw] matched_word
  #   @return [String] lowercased dictionary word (dictionary matches)
  # @!attribute [rw] rank
  #   @return [Integer] frequency rank of the matched word (dictionary matches)
  # @!attribute [rw] dictionary_name
  #   @return [String] source dictionary name (dictionary matches)
  # @!attribute [rw] reversed
  #   @return [Boolean] true when matched in the reversed password
  # @!attribute [rw] l33t
  #   @return [Boolean] true when the match required l33t substitution
  # @!attribute [rw] sub
  #   @return [Hash] map of l33t characters to their substituted letters
  # @!attribute [rw] sub_display
  #   @return [String] human-readable substitution summary
  # @!attribute [rw] guesses
  #   @return [Integer] estimated guess count
  # @!attribute [rw] guesses_log10
  #   @return [Float] log10 of {#guesses}
  # @!attribute [rw] base_guesses
  #   @return [Integer] guesses for the base token (repeat matches)
  # @!attribute [rw] uppercase_variations
  #   @return [Integer] capitalisation variant count
  # @!attribute [rw] l33t_variations
  #   @return [Integer] l33t substitution variant count
  # @!attribute [rw] base_token
  #   @return [String] the minimal repeating unit (repeat matches)
  # @!attribute [rw] repeat_count
  #   @return [Integer] number of repetitions (repeat matches)
  # @!attribute [rw] sequence_name
  #   @return [String] sequence type: "lower", "upper", "digits", or "unicode"
  # @!attribute [rw] sequence_space
  #   @return [Integer] size of the character set for the sequence
  # @!attribute [rw] ascending
  #   @return [Boolean] true if the sequence is ascending
  # @!attribute [rw] graph
  #   @return [String] keyboard graph name (spatial matches)
  # @!attribute [rw] turns
  #   @return [Integer] number of direction changes (spatial matches)
  # @!attribute [rw] shifted_count
  #   @return [Integer] number of shifted characters (spatial matches)
  # @!attribute [rw] year
  #   @return [Integer] matched year (date/year matches)
  # @!attribute [rw] month
  #   @return [Integer] matched month (date matches)
  # @!attribute [rw] day
  #   @return [Integer] matched day (date matches)
  # @!attribute [rw] separator
  #   @return [String] date separator character (date matches)
  class Match
    attr_accessor :pattern, :i, :j, :token, :matched_word, :rank,
                  :dictionary_name, :reversed, :l33t, :sub, :sub_display,
                  :guesses, :guesses_log10, :base_guesses, :uppercase_variations, :l33t_variations,
                  :base_token, :repeat_count,
                  :sequence_name, :sequence_space, :ascending,
                  :graph, :turns, :shifted_count,
                  :year, :month, :day, :separator

    # @param attributes [Hash] keyword arguments for any subset of the match attributes
    def initialize(**attributes)
      attributes.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Returns all non-nil attributes as a plain Hash with string keys.
    #
    # @return [Hash{String => Object}]
    def to_hash
      instance_variables.sort.each_with_object({}) do |var, hash|
        key = var.to_s.delete_prefix('@')
        hash[key] = instance_variable_get(var)
      end
    end
  end
end
