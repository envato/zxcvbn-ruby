# frozen_string_literal: true

require 'zxcvbn/data'
require 'zxcvbn/password_strength'

module Zxcvbn
  # Raised when a password exceeds {Tester::MAX_PASSWORD_LENGTH} characters.
  # Inherits from +ArgumentError+ for backward compatibility with existing
  # +rescue ArgumentError+ clauses.
  class PasswordTooLong < ArgumentError; end

  # Allows you to test the strength of multiple passwords without reading and
  # parsing the dictionary data from disk each test. Dictionary data is read
  # once from disk and stored in memory for the life of the Tester object.
  #
  # Example:
  #
  #   tester = Zxcvbn::Tester.new
  #
  #   tester.add_word_lists("custom" => ["words"])
  #
  #   tester.test("password 1")
  #   tester.test("password 2")
  #   tester.test("password 3")
  class Tester
    # Default maximum password length when no +max_password_length:+ is given
    # to {#initialize}. Passwords longer than this raise {PasswordTooLong}.
    # Defaults to 256; override process-wide by setting the
    # +ZXCVBN_MAX_PASSWORD_LENGTH+ environment variable before the gem loads,
    # or per-instance via <tt>Tester.new(max_password_length: n)</tt>.
    MAX_PASSWORD_LENGTH = begin
      Integer(ENV.fetch('ZXCVBN_MAX_PASSWORD_LENGTH', 256))
    rescue ArgumentError, TypeError
      raise ArgumentError,
            'ZXCVBN_MAX_PASSWORD_LENGTH must be a positive integer; ' \
            "got #{ENV['ZXCVBN_MAX_PASSWORD_LENGTH'].inspect}"
    end

    unless MAX_PASSWORD_LENGTH.positive?
      raise ArgumentError,
            "ZXCVBN_MAX_PASSWORD_LENGTH must be positive; got #{MAX_PASSWORD_LENGTH}"
    end

    # @param max_password_length [Integer] passwords longer than this raise
    #   {PasswordTooLong} from {#test}. Defaults to {MAX_PASSWORD_LENGTH}.
    def initialize(max_password_length: MAX_PASSWORD_LENGTH)
      unless max_password_length.is_a?(Integer) && max_password_length.positive?
        raise ArgumentError,
              "max_password_length must be a positive integer; got #{max_password_length.inspect}"
      end

      @data = Data.new
      @max_password_length = max_password_length
    end

    # Evaluates a password and returns a {Score}.
    #
    # Raises {PasswordTooLong} if the password exceeds the +max_password_length+
    # passed to {#initialize} (default: {MAX_PASSWORD_LENGTH}). The limit exists
    # because scoring time grows super-quadratically on adversarial inputs such
    # as short repeated sequences (e.g. <tt>"ab" * 500</tt>).
    #
    # @param password [String] the password to evaluate
    # @param user_inputs [Array<String>] caller-supplied words to treat as known
    # @return [Score]
    # @raise [PasswordTooLong] if the password exceeds the maximum length
    def test(password, user_inputs = [])
      if password && password.length > @max_password_length
        raise PasswordTooLong,
              "Password exceeds the maximum length of #{@max_password_length}."
      end
      PasswordStrength.new(@data).test(password, sanitize(user_inputs))
    end

    # Adds custom word lists to the loaded data for all future {#test} calls.
    #
    # @param lists [Hash{String => Array<String>}] named word lists
    # @return [void]
    def add_word_lists(lists)
      lists.each_pair { |name, words| @data.add_word_list(name, sanitize(words)) }
    end

    # @return [String] a concise representation that omits the large dictionary data
    def inspect
      "#<#{self.class}:0x#{__id__.to_s(16)}>"
    end

    private

    def sanitize(user_inputs)
      user_inputs.select { |i| i.respond_to?(:downcase) }
    end
  end
end
