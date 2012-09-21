module Zxcvbn
  module Matching
    class Date
      include RegexHelpers

      YEAR_SUFFIX = /
        ( \d{1,2} )                         # day or month
        ( \s | \- | \/ | \\ | \_ | \. )     # separator
        ( \d{1,2} )                         # month or day
        \2                                  # same separator
        ( 19\d{2} | 200\d | 201\d | \d{2} ) # year
      /x

      YEAR_PREFIX = /
        ( 19\d{2} | 200\d | 201\d | \d{2} ) # year
        ( \s | - | \/ | \\ | _ | \. )       # separator
        ( \d{1,2} )                         # day or month
        \2                                  # same separator
        ( \d{1,2} )                         # month or day
      /x

      WITHOUT_SEPARATOR = /\d{4,8}/

      def matches(password)
        result = []
        result += match_with_separator(password)
        result += match_without_separator(password)
        result
      end

      def match_with_separator(password)
        result = []
        re_match_all(YEAR_SUFFIX, password) do |match, re_match|
          result << match
          match.pattern = 'date'
          match.day = re_match[1].to_i
          match.separator = re_match[2]
          match.month = re_match[3].to_i
          match.year = re_match[4].to_i
        end
        result
      end

      def match_without_separator(password)
        result = []
        re_match_all(WITHOUT_SEPARATOR, password) do |match, re_match|
          extract_dates(match.token).each do |candidate|
            day, month, year = candidate[:day], candidate[:month], candidate[:year]

            match = match.dup
            match.pattern = 'date'
            match.day = day
            match.month = month
            match.year = year
            match.separator = ''
            result << match
          end
        end
        result
      end

      def extract_dates(token)
        dates = []
        date_patterns_for_length(token.length).map do |pattern|
          candidate = {
            :year => '',
            :month => '',
            :day => ''
          }
          for i in 0...token.length
            candidate[PATTERN_CHAR_TO_SYM[pattern[i]]] << token[i]
          end
          candidate.each do |component, value|
            candidate[component] = value.to_i
          end
          
          candidate[:year] = expand_year(candidate[:year])
          
          if valid_date?(candidate[:day], candidate[:month], candidate[:year]) && !matches_year?(token)
            dates << candidate
          end
        end
        dates
      end

      DATE_PATTERN_FOR_LENGTH = {
        8 => %w[ yyyymmdd ddmmyyyy mmddyyyy ],
        7 => %w[ yyyymdd yyyymmd ddmyyyy dmmyyyy ],
        6 => %w[ yymmdd ddmmyy mmddyy ],
        5 => %w[ yymdd yymmd ddmyy dmmyy mmdyy mddyy ],
        4 => %w[ yymd dmyy mdyy ]
      }

      PATTERN_CHAR_TO_SYM = {
        'y' => :year,
        'm' => :month,
        'd' => :day
      }

      def date_patterns_for_length(length)
        DATE_PATTERN_FOR_LENGTH[length] || []
      end

      def valid_date?(day, month, year)
        return false if day > 31 || month > 12
        return false unless year >= 1900 && year <= 2019
        true
      end

      def matches_year?(token)
        token.size == 4 && Year::YEAR_REGEX.match(token)
      end

      def expand_year(year)
        return year unless year < 100
        now = Time.now.year
        if year <= 19
          year + 2000
        else
          year + 1900
        end
      end
    end
  end
end