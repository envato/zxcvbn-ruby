# frozen_string_literal: true

module Zxcvbn
  class Match
    attr_accessor :pattern, :i, :j, :token, :matched_word, :rank,
                  :dictionary_name, :reversed, :l33t, :sub, :sub_display,
                  :l, :entropy, :base_entropy, :uppercase_entropy, :l33t_entropy,
                  :guesses, :guesses_log10, :base_guesses, :uppercase_variations, :l33t_variations,
                  :repeated_char, :base_token, :repeat_count, :base_matches,
                  :sequence_name, :sequence_space, :ascending,
                  :graph, :turns, :shifted_count, :shiffted_count,
                  :year, :month, :day, :separator, :cardinality, :offset

    def initialize(**attributes)
      attributes.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def to_hash
      instance_variables.sort.each_with_object({}) do |var, hash|
        key = var.to_s.delete_prefix('@')
        hash[key] = instance_variable_get(var)
      end
    end
  end
end
