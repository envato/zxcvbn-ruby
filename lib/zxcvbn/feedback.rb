

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
      when 'spatial'
        FeedbackSuggest.new('Short keyboard patterns are easy to guess', ['Use a longer keyboard pattern with more turns'])
      when 'repeat'
        FeedbackSuggest.new("Repeats like 'aaa' or 'abcabcabc' are easy to guess", ['Avoid repeated words and characters'])
      when 'sequence'
        FeedbackSuggest.new("Sequences like abc or 6543 are easy to guess", ['Avoid sequences'])
      else
        FeedbackSuggest.new('', [])
      end
    end

  end
end
