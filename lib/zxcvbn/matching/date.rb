module Zxcvbn
  module Matching
    class Date
      include RegexHelpers

      YEAR_SUFFIX = /
        ( \d{1,2} )
        ( \s | \- | \/ | \\ | \_ | \. )
        ( \d{1,2} )                         # month or day
        \2                                  # same separator
        ( 19\d{2} | 200\d | 201\d | \d{2} ) # year
      /x

      YEAR_PREFIX = /
        ( 19\d{2} | 200\d | 201\d | \d{2} ) # year
        ( \s | - | \/ | \\ | _ | \. )        # separator
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
          i, j = match.i, match.j
          token = match.token
          candidates_1 = []

          if token.length <= 6
            candidates_1 << {
              :day_month => token[2..-1],
              :year => token[0..1]
            }
            candidates_1 << {
              :day_month => token[0...token.length-2],
              :year => token[token.length-2..-1]
            }
          end
          if token.length >= 6
            candidates_1 << {
              :day_month => token[4..-1],
              :year => token[0..3]
            }
            candidates_1 << {
              :day_month => token[0..token.length-4],
              :year => token[token.length-1..-1]
            }
          end
          candidates_2 = []
          candidates_1.each do |candidate|
            case candidate[:day_month].length
            when 2
              candidates_2 << {
                :day => candidate[:day_month][0],
                :month => candidate[:day_month][1],
                :year => candidate[:year]
              }
            when 3
              candidates_2 << {
                :day => candidate[:day_month][0..1],
                :month => candidate[:day_month][2],
                :year => candidate[:year]                
              }
              candidates_2 << {
                :day => candidate[:day_month][0],
                :month => candidate[:day_month][1..2],
                :year => candidate[:year]                
              }
            when 4
              candidates_2 << {
                :day => candidate[:day_month][0..1],
                :month => candidate[:day_month][2..3],
                :year => candidate[:year]                
              }              
            end
          end
          # debugger
          candidates_2.each do |candidate|
            # if candidate[:day] > 31 && candidate[:month] > 12
              # candidate[:day], candidate[:month] = candidate[:month], candidate[:day]
            # end
            day, month, year = candidate[:day].to_i, candidate[:month].to_i, candidate[:year].to_i
            
            if valid_date?(day, month, year) &&
                !matches_year?(token)
              match = match.dup
              match.pattern = 'date'
              match.day = day
              match.month = month
              match.year = year
              match.separator = ''
              result << match
            end
          end
        end
        result
      end

      def valid_date?(day, month, year)
        return false if day > 31 || month > 12
        if year < 50
          year += 2000
        elsif year > 50 && year < 100
          year += 1900
        end
        return false unless year >= 1900 && year <= 2019
        true
      end

      def matches_year?(token)
        Year::YEAR_REGEX.match(token)
      end
    end
  end
end