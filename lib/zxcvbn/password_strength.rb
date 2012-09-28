require 'benchmark'

module Zxcvbn
  class PasswordStrength
    def initialize
      @omnimatch = Omnimatch.new
      @scorer = Scorer.new
    end

    def test(password, user_inputs = [])
      password = password || ''
      result = nil
      calc_time = Benchmark.realtime do
        matches = @omnimatch.matches(password, user_inputs)
        result = @scorer.minimum_entropy_match_sequence(password, matches)
      end
      result.calc_time = calc_time
      result
    end
  end
end