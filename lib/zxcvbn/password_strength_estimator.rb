require 'benchmark'

module Zxcvbn
  class PasswordStrengthEstimator
    def initialize
      @omnimatch = Omnimatch.new
    end

    def score(password)
      result = nil
      calc_time = Benchmark.realtime do
        matches = @omnimatch.matches(password)
        result = Scorer.new(password, matches).minimum_entropy_match_sequence
      end
      result.calc_time = calc_time
      result
    end
  end
end