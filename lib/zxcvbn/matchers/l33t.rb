# frozen_string_literal: true

require 'set'

module Zxcvbn
  module Matchers
    class L33t
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

      def initialize(dictionary_matchers)
        @dictionary_matchers = dictionary_matchers
      end

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

      def translate(password, sub)
        result = String.new
        password.each_char do |chr|
          result << (sub[chr] || chr)
        end
        result
      end

      def relevent_l33t_subtable(password)
        filtered = {}
        L33T_TABLE.each do |letter, subs|
          relevent_subs = subs.select { |s| password.include?(s) }
          filtered[letter] = relevent_subs unless relevent_subs.empty?
        end
        filtered
      end

      def l33t_subs(table)
        keys = table.keys
        subs = [[]]
        subs = find_substitutions(subs, table, keys)
        new_subs = []
        subs.each do |sub|
          hash = {}
          sub.each do |l33t_char, chr|
            hash[l33t_char] = chr
          end
          new_subs << hash
        end
        new_subs
      end

      private

      def process_match(match, password, substitution, matches)
        length = match.j - match.i + 1
        token = password.slice(match.i, length)
        return if token.downcase == match.matched_word.downcase

        match_substitutions = {}
        substitution.each do |s, letter|
          match_substitutions[s] = letter if token.include?(s)
        end
        match.l33t = true
        match.token = token
        match.sub = match_substitutions
        match.sub_display = match_substitutions.map do |k, v|
          "#{k} -> #{v}"
        end.join(', ')
        matches << match
      end

      def find_substitutions(subs, table, keys)
        return subs if keys.empty?

        first_key = keys[0]
        rest_keys = keys[1..-1]
        next_subs = []
        table[first_key].each do |l33t_char|
          subs.each do |sub|
            dup_l33t_index = -1
            (0...sub.length).each do |i|
              if sub[i][0] == l33t_char
                dup_l33t_index = i
                break
              end
            end

            if dup_l33t_index == -1
              sub_extension = sub + [[l33t_char, first_key]]
              next_subs << sub_extension
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
