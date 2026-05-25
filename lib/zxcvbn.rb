# frozen_string_literal: true

require 'pathname'
require 'zxcvbn/version'
require 'zxcvbn/tester'

# Ruby port of zxcvbn.js — realistic password strength estimation.
#
# Analyses a password against dictionary lists, keyboard patterns, dates,
# sequences, and repeats to produce a {Score} with guess estimates and
# human-readable crack-time display strings.
module Zxcvbn
  module_function

  DATA_PATH = Pathname(File.expand_path('../data', __dir__))

  # Returns a Zxcvbn::Score for the given password.
  #
  # Scoring time grows with password length: the DP is O(n × m) where n is
  # the password length and m is the number of pattern matches. For
  # adversarial inputs such as short repeated sequences (e.g. "ab" * 500),
  # m also grows with n, producing super-quadratic runtime. Enforce a
  # password length limit appropriate for your use case before calling this.
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
