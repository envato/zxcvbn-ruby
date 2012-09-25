module Zxcvbn
  module Matchers
    class L33t
      L33T_TABLE = {
        'a' => ['4', '@'],
        'b' => ['8'],
        'c' => ['(', '{', '[', '<'],
        'e' => ['3'],
        'g' => ['6', '9'],
        'i' => ['1', '!', '|'],
        'l' => ['1', '|', '7'],
        'o' => ['0'],
        's' => ['$', '5'],
        't' => ['+', '7'],
        'x' => ['%'],
        'z' => ['2']
      }

      def initialize(dictionary_matchers)
        @dictionary_matchers = dictionary_matchers
      end

      def matches(password)
        matches = []
        lowercased_password = password.downcase
        combinations_to_try = l33t_subs(relevent_l33t_subtable(lowercased_password))
        combinations_to_try.each do |substitution|
          @dictionary_matchers.each do |matcher|
            subbed_password = translate(lowercased_password, substitution)
            matcher.matches(subbed_password).each do |match|
              token = password[match.i..match.j]
              next if token.downcase == match.matched_word.downcase
              match_substitutions = {}
              substitution.each do |substitution, letter|
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

      def translate(password, sub)
        password.split('').map do |chr|
          sub[chr] || chr
        end.join
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
        members = []
        subs.each do |sub|
          assoc = sub.dup

          assoc.sort! rescue debugger
          label = assoc.map{|k, v| "#{k},#{v}"}.join('-')
          unless members.include?(label)
            members << label
            deduped << sub
          end
        end
        deduped
      end
    end
  end
end