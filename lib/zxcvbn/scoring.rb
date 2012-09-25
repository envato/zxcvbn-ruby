module Zxcvbn
  class Scoring
    include Math
    
    def initialize(password, matches)
      @password, @matches = password, matches
    end

    def minimum_entropy_match_sequence
      score = Score.new
      score
    end
  end
end