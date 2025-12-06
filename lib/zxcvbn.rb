# frozen_string_literal: true

require 'pathname'
require 'zxcvbn/version'
require 'zxcvbn/tester'

module Zxcvbn
  module_function

  DATA_PATH = Pathname(File.expand_path('../data', __dir__))

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
end
