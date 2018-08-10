

module Zxcvbn
  class Feedback
    FeedbackSuggest = Struct.new(:warning, :suggestions) do
      def to_json
        to_h.to_json
      end
    end

    def initialize(score, sequence)
      @score = score
      @sequence = sequence
    end

    attr_reader :score, :sequence

    def suggestions
      default_suggest = FeedbackSuggest.new('', [
          "Use a few words, avoid common phrases",
          "No need for symbols, digits, or uppercase letters"
          ])

      return default_suggest if sequence.size.zero?
      return FeedbackSuggest.new('', []) if score > 2

      longest_match = sequence.max_by { |x| x.token.length }
      suggest = get_match_feedback(longest_match, sequence.size == 1)
      suggest.suggestions.unshift('Add another word or two. Uncommon words are better.')
      suggest
    end

    def get_match_feedback(match, is_sole_match)
      case match.pattern
      when ''
        FeedbackSuggest.new('', [])
      else
        FeedbackSuggest.new('', [])
      end
    end

  end
end
