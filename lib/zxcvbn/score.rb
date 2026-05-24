# frozen_string_literal: true

module Zxcvbn
  class Score
    attr_accessor :guesses, :crack_time, :crack_time_display, :score,
                  :match_sequence, :password, :calc_time, :feedback

    def initialize(options = {})
      @guesses            = options[:guesses]
      @crack_time         = options[:crack_time]
      @crack_time_display = options[:crack_time_display]
      @score              = options[:score]
      @match_sequence     = options[:match_sequence]
      @password           = options[:password]
    end
  end
end
