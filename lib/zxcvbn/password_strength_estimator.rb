require 'benchmark'

module Zxcvbn
  class PasswordStrengthEstimator
    def initialize
      @omnimatch = Omnimatch.new
      @scorer = Scorer.new
    end

    def score(password)
      result = nil
      calc_time = Benchmark.realtime do
        matches = @omnimatch.matches(password)
        result = @scorer.minimum_entropy_match_sequence(password, matches)
      end
      result.calc_time = calc_time
      result
    end
  end
end