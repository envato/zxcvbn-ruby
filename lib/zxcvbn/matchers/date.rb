# frozen_string_literal: true

module Zxcvbn
  module Matchers
    # Matches date patterns in passwords, both with and without separators.
    # Ported from the zxcvbn v4 JavaScript implementation's +date_match+ function.
    # @api private
    class Date
      # Matches a separator-based date substring (e.g. "02/12/1997", "97-12-02").
      # The first and last groups each allow 1–4 digits so the year may appear in
      # either position; {map_ints_to_dmy} resolves which group is the year.
      MAYBE_DATE_WITH_SEP = %r{\A(\d{1,4})([\s/\\_.-])(\d{1,2})\2(\d{1,4})\z}

      # Matches a run of digits that could be a date without separators.
      MAYBE_DATE_WITHOUT_SEP = /\A\d+\z/

      # Maps token length to split-point pairs for separator-free date parsing.
      # Each pair +[a, b]+ divides the token into three parts: +[0...a]+, +[a...b]+, +[b..]+.
      # Mirrors +DATE_SPLITS+ in the JS v4 source.
      DATE_SPLITS = {
        4 => [[1, 2], [2, 3]],
        5 => [[1, 3], [2, 3]],
        6 => [[1, 2], [2, 4], [4, 5]],
        7 => [[1, 3], [2, 3], [4, 5], [4, 6]],
        8 => [[2, 4], [4, 6]]
      }.freeze

      # Earliest year accepted as a valid date year.
      DATE_MIN_YEAR = 1000

      # Latest year accepted as a valid date year.
      DATE_MAX_YEAR = 2050

      # Returns all date matches found in +password+, deduplicating any match
      # whose character span is fully contained within another match's span.
      #
      # @param password [String] the password to search
      # @param reference_year [Integer] year used to pick the closest candidate for
      #   separator-free dates; defaults to the current year
      # @return [Array<MatchBuilder>] matches with pattern 'date', each containing
      #   +year+, +month+, +day+, and +separator+
      def matches(password, reference_year: Time.now.year)
        all = match_with_separator(password) + match_without_separator(password, reference_year:)
        all.reject do |match|
          all.any? { |other| !other.equal?(match) && other.i <= match.i && other.j >= match.j }
        end
      end

      # Finds date matches that use a separator character (space, slash, hyphen, etc.).
      # Iterates over all substrings of length 6–10 and tests each against
      # {MAYBE_DATE_WITH_SEP}, then resolves day/month/year via {map_ints_to_dmy}.
      #
      # @param password [String] the password to search
      # @return [Array<MatchBuilder>] separator-based date matches
      def match_with_separator(password)
        result = []
        return result if password.length < 6

        (0..(password.length - 6)).each do |i|
          ((i + 5)..[i + 9, password.length - 1].min).each do |j|
            token = password[i..j]
            m = MAYBE_DATE_WITH_SEP.match(token)
            next unless m

            date = map_ints_to_dmy(m[1].to_i, m[3].to_i, m[4].to_i)
            next unless date

            result << MatchBuilder.new(
              i:, j:, token:,
              pattern: 'date',
              separator: m[2],
              year: date[:year],
              month: date[:month],
              day: date[:day]
            )
          end
        end
        result
      end

      # Finds date matches in runs of digits that contain no separator character.
      # Iterates over all digit-only substrings of length 4–8, applies {DATE_SPLITS}
      # to generate day/month/year candidates via {map_ints_to_dmy}, and picks the
      # candidate whose year is closest to the current year.
      #
      # 4-digit tokens that look like standalone years (matched by {Year::YEAR_REGEX})
      # are skipped to avoid treating a year token as a date.
      #
      # @param password [String] the password to search
      # @param reference_year [Integer] year used to pick the closest candidate;
      #   defaults to the current year
      # @return [Array<MatchBuilder>] separator-free date matches
      def match_without_separator(password, reference_year: Time.now.year)
        result = []
        return result if password.length < 4

        (0..(password.length - 4)).each do |i|
          ((i + 3)..[i + 7, password.length - 1].min).each do |j|
            token = password[i..j]
            next unless MAYBE_DATE_WITHOUT_SEP.match?(token)

            splits = DATE_SPLITS[token.length]
            next unless splits
            next if token.length == 4 && Year::YEAR_REGEX.match?(token)

            candidates = splits.filter_map do |a, b|
              map_ints_to_dmy(token[0...a].to_i, token[a...b].to_i, token[b..].to_i)
            end
            next if candidates.empty?

            best = candidates.min_by { |c| (c[:year] - reference_year).abs }

            result << MatchBuilder.new(
              i:, j:, token:,
              pattern: 'date',
              separator: '',
              year: best[:year],
              month: best[:month],
              day: best[:day]
            )
          end
        end
        result
      end

      # Resolves three integers into a +{year:, month:, day:}+ hash, or +nil+ if
      # no valid assignment exists. Mirrors +map_ints_to_dmy+ in the JS v4 source.
      #
      # The middle value (+int2+) is always treated as the non-year component (it
      # comes from the +\d{1,2}+ capture group in the separator regex, or the
      # middle split in the no-separator path). The outer two values are tried as
      # the year: first +int3+, then +int1+. A value in +[DATE_MIN_YEAR, DATE_MAX_YEAR]+
      # is treated as a 4-digit year (takes priority); otherwise both are tried as
      # 2-digit years via {expand_year}.
      #
      # @param int1 [Integer] first integer (leading digits)
      # @param int2 [Integer] middle integer (always the non-year component)
      # @param int3 [Integer] last integer (trailing digits)
      # @return [Hash, nil] +{year:, month:, day:}+ or +nil+ if no valid date
      def map_ints_to_dmy(int1, int2, int3)
        return nil if int2 > 31 || int2 <= 0

        [int1, int2, int3].each do |n|
          return nil if n > 99 && n < DATE_MIN_YEAR
          return nil if n > DATE_MAX_YEAR
        end

        num_over_thirty_one = [int1, int2, int3].count { |n| n > 31 }
        num_over_twelve     = [int1, int2, int3].count { |n| n > 12 }
        num_under_one       = [int1, int2, int3].count { |n| n <= 0 }
        return nil if num_over_thirty_one >= 2 || num_over_twelve == 3 || num_under_one >= 2

        # Try int3 then int1 as the year; 4-digit range takes priority over 2-digit.
        # If a 4-digit candidate is found but day/month are invalid, return nil immediately
        # rather than falling through to the 2-digit pass.
        pairs = [[int3, int1, int2], [int1, int2, int3]]
        four_digit = pairs.find { |yc, _dm1, _dm2| yc.between?(DATE_MIN_YEAR, DATE_MAX_YEAR) }
        if four_digit
          year_candidate, dm1, dm2 = four_digit
          dm = map_ints_to_dm(dm1, dm2)
          return dm ? { year: year_candidate, month: dm[:month], day: dm[:day] } : nil
        end

        # Fall back to 2-digit year
        pairs.each do |year_candidate, dm1, dm2|
          dm = map_ints_to_dm(dm1, dm2)
          next unless dm

          return { year: expand_year(year_candidate), month: dm[:month], day: dm[:day] }
        end

        nil
      end

      # Tries to assign two integers to day and month. Attempts both orderings
      # and returns the first that satisfies +1 ≤ day ≤ 31+ and +1 ≤ month ≤ 12+.
      # Mirrors +map_ints_to_dm+ in the JS v4 source.
      #
      # @param day_val [Integer] candidate day value
      # @param month_val [Integer] candidate month value
      # @return [Hash, nil] +{day:, month:}+ or +nil+ if neither ordering is valid
      def map_ints_to_dm(day_val, month_val)
        [[day_val, month_val], [month_val, day_val]].each do |day, month|
          return { day:, month: } if day.between?(1, 31) && month >= 1 && month <= 12
        end
        nil
      end

      # Returns +true+ if +token+ is a 4-digit string that looks like a standalone
      # year (matched by {Year::YEAR_REGEX}), used to avoid double-counting year
      # tokens as no-separator dates.
      #
      # @param token [String] the token to test
      # @return [Boolean]
      def matches_year?(token)
        token.size == 4 && Year::YEAR_REGEX.match?(token)
      end

      # Expands a 2-digit year to 4 digits. Values above 99 are returned unchanged.
      # Mirrors +two_to_four_digit_year+ in the JS v4 source.
      #
      # @param year [Integer] the year value to expand
      # @return [Integer] 4-digit year
      def expand_year(year)
        return year if year > 99

        year > 50 ? year + 1900 : year + 2000
      end
    end
  end
end
