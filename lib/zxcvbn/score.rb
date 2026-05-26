# frozen_string_literal: true

module Zxcvbn
  # The result of analysing a password — returned by {Zxcvbn.test}.
  #
  # @!attribute [r] password
  #   @return [String] the password that was evaluated
  # @!attribute [r] guesses
  #   @return [Numeric] estimated number of guesses to crack the password
  # @!attribute [r] sequence
  #   @return [Array<Match>] the optimal match sequence
  # @!attribute [r] crack_times_seconds
  #   @return [Hash{String => Float}] crack time in seconds per attack scenario
  # @!attribute [r] crack_times_display
  #   @return [Hash{String => String}] human-readable crack times per scenario
  # @!attribute [r] score
  #   @return [Integer] 0–4 score (0 = very weak, 4 = very strong)
  # @!attribute [r] calc_time
  #   @return [Float, nil] time taken to evaluate, in seconds
  # @!attribute [r] feedback
  #   @return [Feedback, nil] human-readable feedback for low-scoring passwords
  Score = ::Data.define(
    :password, :guesses, :sequence, :crack_times_seconds,
    :crack_times_display, :score, :calc_time, :feedback
  ) do
    def initialize(calc_time: nil, feedback: nil, **kwargs)
      super(calc_time:, feedback:, **kwargs)
    end

    # @return [Float, nil] log10 of {#guesses}, or nil if guesses is not set
    def guesses_log10
      ::Math.log10(guesses) if guesses
    end
  end
end
