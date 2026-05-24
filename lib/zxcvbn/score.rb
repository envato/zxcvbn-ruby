# frozen_string_literal: true

module Zxcvbn
  class Score
    attr_accessor :guesses, :crack_times_seconds, :crack_times_display, :score,
                  :sequence, :password, :calc_time, :feedback

    def initialize(options = {})
      @guesses             = options[:guesses]
      @crack_times_seconds = options[:crack_times_seconds]
      @crack_times_display = options[:crack_times_display]
      @score               = options[:score]
      @sequence            = options[:sequence]
      @password            = options[:password]
    end
  end
end
