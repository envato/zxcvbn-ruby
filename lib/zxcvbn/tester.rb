# frozen_string_literal: true

require 'zxcvbn/clock'
require 'zxcvbn/feedback_giver'
require 'zxcvbn/omnimatch'
require 'zxcvbn/scorer'

module Zxcvbn
  # Raised when a password exceeds the configured maximum length.
  # Inherits from +ArgumentError+ for backward compatibility with existing
  # +rescue ArgumentError+ clauses.
  class PasswordTooLong < ArgumentError; end

  # Evaluates password strength against dictionary lists, keyboard patterns,
  # dates, sequences, and repeats. Construct via {Zxcvbn.tester}:
  #
  #   tester = Zxcvbn.tester
  #     .add_word_list('company', %w[acme corp])
  #     .build
  #
  #   tester.test("password 1")
  #   tester.test("password 2")
  class Tester
    # @param data [Data] pre-configured data
    # @param max_password_length [Integer] passwords longer than this raise
    #   {PasswordTooLong} from {#test}
    # @raise [ArgumentError] if max_password_length is not a positive integer
    def initialize(data:, max_password_length:)
      unless max_password_length.is_a?(Integer) && max_password_length.positive?
        raise ArgumentError,
              "max_password_length must be a positive integer; got #{max_password_length.inspect}"
      end

      @data = data
      @max_password_length = max_password_length
      @omnimatch = Omnimatch.new(@data)
    end

    attr_reader :max_password_length

    # Evaluates a password and returns a {Score}.
    #
    # Raises {PasswordTooLong} if the password exceeds the +max_password_length+
    # passed to {#initialize}. The limit exists because scoring time grows
    # super-quadratically on adversarial inputs such as short repeated sequences
    # (e.g. <tt>"ab" * 500</tt>).
    #
    # @param password [String] the password to evaluate
    # @param user_inputs [Array<String>] caller-supplied words to treat as known
    # @return [Score]
    # @raise [PasswordTooLong] if the password exceeds the maximum length
    def test(password, user_inputs = [])
      password ||= ''
      if password.length > @max_password_length
        raise PasswordTooLong, "Password exceeds the maximum length of #{@max_password_length}."
      end

      result = nil
      calc_time = Clock.realtime do
        reference_year = Time.now.year
        scorer = Scorer.new(@data, @omnimatch, reference_year)
        matches = @omnimatch.matches(password, user_inputs, reference_year:)
        result = scorer.most_guessable_match_sequence(password, matches)
      end
      result.with(
        calc_time:,
        feedback: FeedbackGiver.get_feedback(result.score, result.sequence)
      )
    end

    # @return [String] a concise representation that omits the large dictionary data
    def inspect
      "#<#{self.class}:0x#{__id__.to_s(16)}>"
    end
  end
end
