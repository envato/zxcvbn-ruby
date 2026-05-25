# frozen_string_literal: true

module Zxcvbn
  module Matchers
    # Matches dictionary words after substituting common l33t-speak character
    # replacements (e.g. "@" for "a", "3" for "e").
    class L33t
      # Mapping from plain letter to the l33t characters that can represent it.
      L33T_TABLE = {
        'a' => ['4', '@'].freeze,
        'b' => ['8'].freeze,
        'c' => ['(', '{', '[', '<'].freeze,
        'e' => ['3'].freeze,
        'g' => ['6', '9'].freeze,
        'i' => ['1', '!', '|'].freeze,
        'l' => ['1', '|', '7'].freeze,
        'o' => ['0'].freeze,
        's' => ['$', '5'].freeze,
        't' => ['+', '7'].freeze,
        'x' => ['%'].freeze,
        'z' => ['2'].freeze
      }.freeze

      # @param dictionary_matchers [Array<Dictionary>] matchers to run against substituted passwords
      def initialize(dictionary_matchers)
        @dictionary_matchers = dictionary_matchers
      end

      # Returns l33t-substituted dictionary matches found in password.
      #
      # @param password [String]
      # @return [Array<MatchBuilder>] matches with pattern "dictionary" and l33t: true
      def matches(password)
        matches = []
        lowercased_password = password.downcase
        relevent_subtable = relevent_l33t_subtable(lowercased_password)

        # Early bailout: if no l33t characters present, return empty matches
        return matches if relevent_subtable.empty?

        combinations_to_try = l33t_subs(relevent_subtable)
        combinations_to_try.each do |substitution|
          @dictionary_matchers.each do |matcher|
            subbed_password = translate(lowercased_password, substitution)
            matcher.matches(subbed_password).each do |match|
              process_match(match, password, substitution, matches)
            end
          end
        end
        matches
      end

      # Returns a copy of password with each character replaced according to sub.
      #
      # @param password [String]
      # @param sub [Hash{String => String}] character substitution map
      # @return [String]
      def translate(password, sub)
        password.gsub(Regexp.union(sub.keys), sub)
      end

      # Returns the subset of {L33T_TABLE} whose l33t characters appear in password.
      #
      # @param password [String] lowercased password
      # @return [Hash{String => Array<String>}]
      def relevent_l33t_subtable(password)
        filtered = {}
        L33T_TABLE.each do |letter, subs|
          relevent_subs = subs.select { |s| password.include?(s) }
          filtered[letter] = relevent_subs unless relevent_subs.empty?
        end
        filtered
      end

      # Enumerates all possible substitution combinations for the given l33t subtable.
      #
      # @param table [Hash{String => Array<String>}] relevant l33t subtable
      # @return [Array<Hash{String => String}>] list of substitution maps to try
      def l33t_subs(table)
        keys = table.keys
        subs = [[]]
        subs = find_substitutions(subs, table, keys)
        subs.map(&:to_h)
      end

      private

      def process_match(match, password, substitution, matches)
        length = match.j - match.i + 1
        token = password.slice(match.i, length)
        return if token.downcase == match.matched_word.downcase

        match_substitutions = substitution.select { |s, _| token.include?(s) }
        match.l33t = true
        match.token = token
        match.sub = match_substitutions
        match.sub_display = match_substitutions.map { |k, v| "#{k} -> #{v}" }.join(', ')
        matches << match
      end

      def find_substitutions(subs, table, keys)
        return subs if keys.empty?

        first_key = keys[0]
        rest_keys = keys[1..]
        next_subs = []
        table[first_key].each do |l33t_char|
          subs.each do |sub|
            dup_l33t_index = sub.find_index { |pair| pair[0] == l33t_char }

            if dup_l33t_index.nil?
              next_subs << (sub + [[l33t_char, first_key]])
            else
              sub_alternative = sub.dup
              sub_alternative[dup_l33t_index, 1] = [[l33t_char, first_key]]
              next_subs << sub
              next_subs << sub_alternative
            end
          end
        end
        subs = dedup(next_subs)
        find_substitutions(subs, table, rest_keys)
      end

      def dedup(subs)
        deduped = []
        seen = Set.new
        subs.each do |sub|
          # Sort and convert to hash for consistent comparison
          sorted_sub = sub.sort.to_h
          unless seen.include?(sorted_sub)
            seen.add(sorted_sub)
            deduped << sub
          end
        end
        deduped
      end
    end
  end
end
