# frozen_string_literal: true

require 'zxcvbn/version'
require 'zxcvbn/tester'
require 'zxcvbn/tester_builder'

# Ruby port of zxcvbn.js — realistic password strength estimation.
#
# Analyses a password against dictionary lists, keyboard patterns, dates,
# sequences, and repeats to produce a {Score} with guess estimates and
# human-readable crack-time display strings.
module Zxcvbn
  module_function

  # Mutex protecting lazy initialisation of the shared default {Tester}.
  DEFAULT_TESTER_MUTEX = Mutex.new
  private_constant :DEFAULT_TESTER_MUTEX

  # Returns a Zxcvbn::Score for the given password.
  #
  # Reuses a shared {Tester} instance across calls. For custom word lists or
  # options, use {.tester} to build a dedicated {Tester}.
  #
  # Raises {PasswordTooLong} (a subclass of +ArgumentError+) if the password
  # exceeds the configured limit (default: 256 characters). Override process-wide
  # via the +ZXCVBN_MAX_PASSWORD_LENGTH+ environment variable; for per-call limits,
  # use {.tester} with {TesterBuilder#max_password_length}.
  #
  # Example:
  #
  #   Zxcvbn.test("password").score #=> 0
  #
  # @param password [String] the password to evaluate
  # @param user_inputs [Array<String>] caller-supplied words to treat as known
  # @return [Score]
  # @raise [PasswordTooLong] if the password exceeds the maximum length
  def test(password, user_inputs = [])
    default_tester.test(password, user_inputs)
  end

  # Returns a new {TesterBuilder} for constructing a {Tester} with custom
  # word lists and options.
  #
  # Example:
  #
  #   tester = Zxcvbn.tester
  #     .add_word_list('company', %w[acme corp])
  #     .max_password_length(75)
  #     .build
  #
  # @return [TesterBuilder]
  def tester
    TesterBuilder.new
  end

  # @return [Tester] the shared default tester, constructed on first call
  def default_tester
    DEFAULT_TESTER_MUTEX.synchronize { @default_tester ||= tester.build }
  end
  private_class_method :default_tester
end
