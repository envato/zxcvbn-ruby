require 'pathname'
require 'zxcvbn/version'
require 'zxcvbn/tester'

module Zxcvbn
  extend self

  DATA_PATH = Pathname(File.expand_path('../../data', __FILE__))

  # Returns a Zxcvbn::Score for the given password
  #
  # Example:
  #
  #   Zxcvbn.test("password").score #=> 0
  def test(password, user_inputs = [])
    tester = Tester.new
    tester.test(password, user_inputs)
  end
end
