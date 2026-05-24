# frozen_string_literal: true

module Zxcvbn
  # The result of analysing a password — returned by {Zxcvbn.test}.
  #
  # @!attribute [rw] guesses
  #   @return [Integer] estimated number of guesses to crack the password
  # @!attribute [rw] crack_times_seconds
  #   @return [Hash{String => Float}] crack time in seconds per attack scenario
  # @!attribute [rw] crack_times_display
  #   @return [Hash{String => String}] human-readable crack times per scenario
  # @!attribute [rw] score
  #   @return [Integer] 0–4 score (0 = very weak, 4 = very strong)
  # @!attribute [rw] sequence
  #   @return [Array<Match>] the optimal match sequence
  # @!attribute [rw] password
  #   @return [String] the password that was evaluated
  # @!attribute [rw] calc_time
  #   @return [Float] time taken to evaluate, in seconds
  # @!attribute [rw] feedback
  #   @return [Feedback] human-readable feedback for low-scoring passwords
  class Score
    attr_accessor :guesses, :crack_times_seconds, :crack_times_display, :score,
                  :sequence, :password, :calc_time, :feedback

    # @return [Float, nil] log10 of {#guesses}, or nil if guesses is not set
    def guesses_log10
      ::Math.log10(@guesses) if @guesses
    end

    # @param options [Hash]
    # @option options [Integer] :guesses
    # @option options [Hash] :crack_times_seconds
    # @option options [Hash] :crack_times_display
    # @option options [Integer] :score
    # @option options [Array<Match>] :sequence
    # @option options [String] :password
    def initialize(options = {})
      @guesses             = options[:guesses]
      @crack_times_seconds = options[:crack_times_seconds]
      @crack_times_display = options[:crack_times_display]
      @score               = options[:score]
      @sequence            = options[:sequence]
      @password            = options[:password]
    end
  end
end
