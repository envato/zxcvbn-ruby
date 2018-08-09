require 'pathname'
require 'zxcvbn/version'
require 'zxcvbn/tester'
require 'zxcvbn/feedback'

module Zxcvbn
  extend self

  DATA_PATH = Pathname(File.expand_path('../../data', __FILE__))

  # Returns a Zxcvbn::Score for the given password
  #
  # Example:
  #
  #   Zxcvbn.test("password").score #=> 0
  def test(password, user_inputs = [], word_lists = {})
    tester = Tester.new
    tester.add_word_lists(word_lists)
    tester.test(password, user_inputs)
  end

  def feedback(score)
    Feedback.new(score.score, score.match_sequence).suggestions
  end
end
