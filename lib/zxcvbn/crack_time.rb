# frozen_string_literal: true

module Zxcvbn
  module CrackTime
    SINGLE_GUESS = 0.010
    NUM_ATTACKERS = 100

    SECONDS_PER_GUESS = SINGLE_GUESS / NUM_ATTACKERS

    def entropy_to_crack_time(entropy)
      0.5 * (2**entropy) * SECONDS_PER_GUESS
    end

    def crack_time_to_score(seconds)
      if seconds < 10**2
        0
      elsif seconds < 10**4
        1
      elsif seconds < 10**6
        2
      elsif seconds < 10**8
        3
      else
        4
      end
    end

    def display_time(seconds)
      minute  = 60
      hour    = minute * 60
      day     = hour * 24
      month   = day * 31
      year    = month * 12
      century = year * 100

      if seconds < minute
        'instant'
      elsif seconds < hour
        "#{1 + (seconds / minute).ceil} minutes"
      elsif seconds < day
        "#{1 + (seconds / hour).ceil} hours"
      elsif seconds < month
        "#{1 + (seconds / day).ceil} days"
      elsif seconds < year
        "#{1 + (seconds / month).ceil} months"
      elsif seconds < century
        "#{1 + (seconds / year).ceil} years"
      else
        'centuries'
      end
    end
  end
end
