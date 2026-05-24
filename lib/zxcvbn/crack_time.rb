# frozen_string_literal: true

module Zxcvbn
  module CrackTime
    ATTACK_SCENARIOS = {
      'online_throttling_100_per_hour' => 100.0 / 3600,
      'online_no_throttling_10_per_second' => 10.0,
      'offline_slow_hashing_1e4_per_second' => 1e4,
      'offline_fast_hashing_1e10_per_second' => 1e10
    }.freeze

    # Returns the estimated seconds and display strings for each attack scenario.
    #
    # @param guesses [Numeric] estimated guess count
    # @return [Hash] with :crack_times_seconds and :crack_times_display
    def estimate_attack_times(guesses)
      seconds = ATTACK_SCENARIOS.transform_values { |rate| guesses / rate }
      display = seconds.transform_values { |s| display_time(s) }
      { crack_times_seconds: seconds, crack_times_display: display }
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
