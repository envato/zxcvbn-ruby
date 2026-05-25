# frozen_string_literal: true

require 'zxcvbn/clock'
require 'zxcvbn/feedback_giver'
require 'zxcvbn/omnimatch'
require 'zxcvbn/scorer'

module Zxcvbn
  # Analyses a single password and returns a {Score}.
  class PasswordStrength
    # @param data [Data] loaded frequency lists and adjacency graphs
    def initialize(data)
      @omnimatch = Omnimatch.new(data)
      @scorer = Scorer.new(data)
    end

    # Analyses password strength and returns a populated {Score}.
    #
    # @param password [String] the password to evaluate
    # @param user_inputs [Array<String>] caller-supplied words to treat as known dictionary entries
    # @return [Score]
    def test(password, user_inputs = [])
      password ||= ''
      result = nil
      calc_time = Clock.realtime do
        matches = @omnimatch.matches(password, user_inputs)
        result = @scorer.most_guessable_match_sequence(password, matches, user_inputs:)
      end
      result.with(
        calc_time:,
        feedback: FeedbackGiver.get_feedback(result.score, result.sequence)
      )
    end
  end
end
