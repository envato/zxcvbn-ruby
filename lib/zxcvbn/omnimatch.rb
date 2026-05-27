# frozen_string_literal: true

require 'zxcvbn/dictionary_ranker'
require 'zxcvbn/trie'
require 'zxcvbn/matchers/dictionary'
require 'zxcvbn/matchers/l33t'
require 'zxcvbn/matchers/spatial'
require 'zxcvbn/matchers/digits'
require 'zxcvbn/matchers/repeat'
require 'zxcvbn/matchers/sequences'
require 'zxcvbn/matchers/year'
require 'zxcvbn/matchers/date'

module Zxcvbn
  # Runs all registered matchers against a password and aggregates results.
  #
  # Includes dictionary, l33t, spatial, digit, repeat, sequence, year, date,
  # and reverse-dictionary matchers. User-supplied word lists are wrapped in
  # transient matchers for each call to {#matches}.
  # @api private
  class Omnimatch
    # @param data [Data] loaded frequency lists and adjacency graphs
    def initialize(data)
      @data = data
      dicts = data.dictionaries
      @dictionary_matchers = dicts.ranked.map do |name, dictionary|
        Matchers::Dictionary.new(name, dictionary, dicts.tries[name]).freeze
      end.freeze
      @matchers = build_matchers.each(&:freeze).freeze
    end

    # Returns all matches found in the password across every registered matcher.
    #
    # @param password [String] the password to analyse
    # @param user_inputs [Array<String>] caller-supplied words to add as a dictionary
    # @param reference_year [Integer] year used by the date matcher to pick the closest
    #   candidate; shared with the scorer so both phases agree even across midnight
    # @return [Array<MatchBuilder>]
    def matches(password, user_inputs = [], reference_year: Time.now.year)
      user_inputs = user_inputs.select { |i| i.respond_to?(:downcase) }
      user_dictionary =
        user_inputs.any? && Matchers::Dictionary.new('user_inputs', DictionaryRanker.rank_dictionary(user_inputs))
      matchers = @matchers + user_input_matchers(user_dictionary)
      all_matches = matchers.flat_map do |matcher|
        case matcher
        when Matchers::Date
          matcher.matches(password, reference_year:)
        else
          matcher.matches(password)
        end
      end
      all_matches + reverse_dictionary_matches(password, user_dictionary)
    end

    private

    def user_input_matchers(user_dictionary)
      return [] unless user_dictionary

      [user_dictionary, Matchers::L33t.new([user_dictionary])]
    end

    # Run dictionary matchers on the reversed password and flip match positions
    # back to the original password's coordinate space.
    #
    # This catches passwords like "drowssap" (reversed "password").
    # Each returned match has reversed: true and its token restored to the
    # original (un-reversed) form.
    #
    # @param password [String] the original password
    # @param user_dictionary [Matchers::Dictionary, nil] pre-built user input matcher
    # @return [Array<MatchBuilder>] dictionary matches found in the reversed password
    def reverse_dictionary_matches(password, user_dictionary)
      reversed = password.reverse
      n = password.length

      matchers = @dictionary_matchers
      matchers += [user_dictionary] if user_dictionary

      matches = []
      matchers.each do |matcher|
        matcher.matches(reversed).each do |match|
          match.token    = match.token.reverse
          match.reversed = true
          old_i  = match.i
          old_j  = match.j
          match.i = n - 1 - old_j
          match.j = n - 1 - old_i
          matches << match
        end
      end
      matches
    end

    def build_matchers
      @dictionary_matchers + [
        Matchers::L33t.new(@dictionary_matchers),
        Matchers::Spatial.new(@data.adjacency_graphs),
        Matchers::Digits.new,
        Matchers::Repeat.new,
        Matchers::Sequences.new,
        Matchers::Year.new,
        Matchers::Date.new
      ]
    end
  end
end
