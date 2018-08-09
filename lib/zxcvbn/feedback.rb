FeedbackSuggest = Struct.new(:warning, :suggestions)

module Zxcvbn
  class Feedback
    def initialize(score, sequence)
      @score = score
      @sequence = sequence
    end

    attr_reader :score, :sequence

    def suggestions
      suggest = FeedbackSuggest.new('', [
          "Use a few words, avoid common phrases",
          "No need for symbols, digits, or uppercase letters"
          ])

      return suggest if sequence.size.zero?
      return FeedbackSuggest.new('', []) if score > 2
      suggest
    end
  end
end
