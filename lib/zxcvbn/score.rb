module Zxcvbn
  class Score
    attr_accessor :entropy, :crack_time, :crack_time_display, :score, :pattern

    def initialize
      @entropy            = 0
      @crack_time         = 0
      @crack_time_display = 'instant'
      @score              = 0
    end
  end
end