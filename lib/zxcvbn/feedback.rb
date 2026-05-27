# frozen_string_literal: true

module Zxcvbn
  # Human-readable feedback for a low-scoring password.
  #
  # @!attribute [r] warning
  #   @return [String] a single warning message, or empty string
  # @!attribute [r] suggestions
  #   @return [Array<String>] ordered list of improvement tips
  Feedback = ::Data.define(:warning, :suggestions) do
    # @param warning [String] warning message (default: empty string)
    # @param suggestions [Array<String>] improvement tips (default: [])
    def initialize(warning: nil, suggestions: [])
      super(warning: warning || '', suggestions: suggestions.freeze)
    end
  end
end
