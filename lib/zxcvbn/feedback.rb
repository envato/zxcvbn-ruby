# frozen_string_literal: true

module Zxcvbn
  # Human-readable feedback for a low-scoring password.
  #
  # @!attribute [rw] warning
  #   @return [String] a single warning message, or empty string
  # @!attribute [rw] suggestions
  #   @return [Array<String>] ordered list of improvement tips
  class Feedback
    attr_accessor :warning, :suggestions

    # @param options [Hash]
    # @option options [String] :warning warning message (default: empty string)
    # @option options [Array<String>] :suggestions improvement tips (default: [])
    def initialize(options = {})
      @warning     = options[:warning] || ''
      @suggestions = options[:suggestions] || []
    end
  end
end
