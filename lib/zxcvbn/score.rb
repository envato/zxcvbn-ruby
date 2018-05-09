module Zxcvbn
  class Score
    attr_accessor :entropy, :crack_time, :crack_time_display, :score, :pattern,
                  :match_sequence, :password, :calc_time, :feedback

    def initialize(options = {})
      @entropy            = options[:entropy]
      @crack_time         = options[:crack_time]
      @crack_time_display = options[:crack_time_display]
      @score              = options[:score]
      @match_sequence     = options[:match_sequence]
      @password           = options[:password]
    end
  end
end