# frozen_string_literal: true

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
        combinations_to_try = substitution_combinations(relevant_l33t_substitutions(lowercased_password))
        combinations_to_try.each do |substitutions|
          @dictionary_matchers.each do |matcher|
            subbed_password = substitute(lowercased_password, substitutions)
            matcher.matches(subbed_password).each do |match|
              token = lowercased_password[match.i..match.j]
              next if token == match.matched_word.downcase

              match_substitutions = {}
              substitutions.each do |letter, substitution|
                match_substitutions[substitution] = letter if token.include?(substitution)
              end
              match.l33t = true
              match.token = password[match.i..match.j]
              match.sub = match_substitutions
              match.sub_display = match_substitutions.map do |k, v|
                "#{k} -> #{v}"
              end.join(', ')
              matches << match
            end
          end
        end
        matches
      end

      def substitute(password, substitutions)
        subbed_password = password.dup
        substitutions.each do |letter, substitution|
          subbed_password.gsub!(substitution, letter)
        end
        subbed_password
      end

      # produces a l33t table of substitutions present in the given password
      def relevant_l33t_substitutions(password)
        subs = Hash.new do |hash, key|
          hash[key] = []
        end
        L33T_TABLE.each do |letter, substibutions|
          password.each_char do |password_char|
            subs[letter] << password_char if substibutions.include?(password_char)
          end
        end
        subs
      end

      # takes a character substitutions hash and produces an array of all
      # possible substitution combinations
      def substitution_combinations(subs_hash)
        combinations = []
        expanded_substitutions = expanded_substitutions(subs_hash)

        # build an array of all possible combinations
        expanded_substitutions.each do |substitution_hash|
          # convert a hash to an array of hashes with 1 key each
          subs_array = substitution_hash.map do |letter, substitutions|
            { letter => substitutions }
          end
          combinations << subs_array

          # find all possible combinations for each number of combinations available
          subs_array.combination(subs_array.size).each do |combination|
            # Don't add duplicates
            combinations << combination unless combinations.include?(combination)
          end
        end

        # convert back to simple hash per substitution combination
        combinations.map do |combination_set|
          hash = {}
          combination_set.each do |combination_hash|
            hash.merge!(combination_hash)
          end
          hash
        end
      end

      # expand possible combinations if multiple characters can be substituted
      # e.g. {'a' => ['4', '@'], 'i' => ['1']} expands to
      #      [{'a' => '4', 'i' => 1}, {'a' => '@', 'i' => '1'}]
      def expanded_substitutions(hash)
        return {} if hash.empty?

        values = hash.values
        product_values = values[0].product(*values[1..-1])
        product_values.map { |p| Hash[hash.keys.zip(p)] }
      end
    end
  end
end
