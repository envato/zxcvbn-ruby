# frozen_string_literal: true

require 'zxcvbn/clock'
require 'zxcvbn/feedback_giver'
require 'zxcvbn/omnimatch'
require 'zxcvbn/scorer'

module Zxcvbn
  class PasswordStrength
    MAX_PASSWORD_LENGTH = 256

    def initialize(data)
      @omnimatch = Omnimatch.new(data)
      @scorer = Scorer.new(data)
    end

    def test(password, user_inputs = [])
      password = (password || '').slice(0, MAX_PASSWORD_LENGTH)
      result = nil
      calc_time = Clock.realtime do
        matches = @omnimatch.matches(password, user_inputs)
        result = @scorer.most_guessable_match_sequence(password, matches, user_inputs: user_inputs)
      end
      result.calc_time = calc_time
      result.feedback = FeedbackGiver.get_feedback(result.score, result.match_sequence)
      result
    end
  end
end
