module Zxcvbn
  class Scoring
    def initialize(password, matches)
      @password, @matches = password, matches
    end

    def minimum_entropy_match_sequence
      Score.new(@password)
    end
  end
end