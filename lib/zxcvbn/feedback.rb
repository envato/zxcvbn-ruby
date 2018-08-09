FeedbackSuggest = Struct.new(:warning, :suggestions) do
  def to_json
    to_h.to_json
  end
end

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

      extra_feedback = 'Add another word or two. Uncommon words are better.'
      if !suggest.suggestions.empty?
        suggest.suggestions.unshift extra_feedback
      else
        suggest = FeedbackSuggest.new('', [extra_feedback])
      end
      suggest
    end
  end
end
