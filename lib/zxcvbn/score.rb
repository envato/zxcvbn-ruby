module Zxcvbn
  class Score
    module Math
      def bruteforce_cardinality
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
    end
    
    include Math
    attr_accessor :password, :entropy, :crack_time, :crack_time_display, :score, :pattern

    def initialize(password)
      @password = password
      @entropy = 0
      @crack_time = 0
      @crack_time_display = 'instant'
      @score = 0
    end
    
  end

end