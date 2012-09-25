module Zxcvbn
  class Score
    module Math
      def bruteforce_cardinality(password)
        is_type_of = {}
        
        password.each_byte do |ordinal|
          case ordinal
          when (48..57)
            is_type_of['digits'] = true
          when(65..90)
            is_type_of['upper'] = true
          when(97..122)
            is_type_of['lower'] = true
          else
            is_type_of['symbols'] = true
          end
        end
        
        cardinality = 0
        cardinality += 10 if is_type_of['digits']
        cardinality += 26 if is_type_of['upper']
        cardinality += 26 if is_type_of['lower']
        cardinality += 33 if is_type_of['symbols']
        cardinality
      end

      # def display_time(seconds)
      #   minute  = 60
      #   hour    = minute * 60
      #   day     = hour * 24
      #   month   = day * 31
      #   year    = month * 12
      #   century = year * 100

      #   if seconds < minute
      #     'instant'
      #   elsif seconds < hour
      #     "#{1 + (seconds / minute).ceil} minutes"
      #   else if seconds < day
      #     "#{1 + (seconds / hour).ceil} hours"
      #   else if seconds < month
      #     "#{1 + (seconds / day).ceil} days"
      #   else if seconds < year
      #     "#{1 + (seconds / month).ceil} months"
      #   else if seconds < century
      #     "#{1 + (seconds / year).ceil} years"
      #   else
      #     'centuries'
      #   end
      # end
    end
  end    
end