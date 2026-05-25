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
  # Reuses a shared {Tester} instance (with pre-loaded dictionaries) when no
  # custom +word_lists+ are given. For repeated calls without custom word lists,
  # this is equivalent to using {Tester} directly. When +word_lists+ are
  # provided, a fresh {Tester} is constructed each call.
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
    if word_lists.empty?
      @default_tester ||= Tester.new
      @default_tester.test(password, user_inputs)
    else
      tester = Tester.new
      tester.add_word_lists(word_lists)
      tester.test(password, user_inputs)
    end
  end
end
