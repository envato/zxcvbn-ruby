# frozen_string_literal: true

module Zxcvbn
  module CrackTime
    SINGLE_GUESS = 0.010
    NUM_ATTACKERS = 100

    SECONDS_PER_GUESS = SINGLE_GUESS / NUM_ATTACKERS

    def entropy_to_crack_time(entropy)
      0.5 * (2**entropy) * SECONDS_PER_GUESS
    end

    # Convert a guess count to a 0–4 score using zxcvbn.js v4 thresholds.
    #
    # A small delta (5) is added to each threshold so that passwords just at
    # a boundary are not bumped up to the next score band by floating-point
    # noise in the guess count.
    #
    # @param guesses [Numeric] estimated number of guesses to crack the password
    # @return [Integer] score in the range 0..4
    def guesses_to_score(guesses)
      delta = 5
      if guesses < 1_000 + delta
        0
      elsif guesses < 1_000_000 + delta
        1
      elsif guesses < 100_000_000 + delta
        2
      elsif guesses < 10_000_000_000 + delta
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
