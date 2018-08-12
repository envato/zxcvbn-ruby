

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
      suggest = get_pattern_match_feedback(longest_match)
      suggest.suggestions.unshift('Add another word or two. Uncommon words are better.')
      suggest
    end

    private

    def get_pattern_match_feedback(match)
      case match.pattern
      when 'dictionary'
        get_dictionary_match_feedback(match)
      when 'spatial'
        FeedbackSuggest.new('Short keyboard patterns are easy to guess', ['Use a longer keyboard pattern with more turns'])
      when 'repeat'
        FeedbackSuggest.new("Repeats like 'aaa' or 'abcabcabc' are easy to guess", ['Avoid repeated words, characters and numbers'])
      when 'sequence'
        FeedbackSuggest.new("Sequences like abc or 6543 are easy to guess", ['Avoid sequences'])
      when 'year'
        FeedbackSuggest.new("Years are easy to guess", ['Avoid recent years or years that are associated with you'])
      else
        FeedbackSuggest.new('', [])
      end
    end

    def get_dictionary_match_feedback(match)
      warning = get_dictionary_warning(match)
      suggestion = get_dictionary_suggestion(match)
      FeedbackSuggest.new(warning, [suggestion])
    end

    def get_dictionary_warning(match)
      if match.dictionary_name == "passwords"
        "This is similar to a commonly used password"
      elsif match.dictionary_name == "english"
        "Simple passwords with a few comomon words are easy to guess"
      elsif ['surnames', 'male_names', 'female_names'].include?(match.dictionary_name)
        "Common names and surnames are easy to guess"
      end
    end

    def get_dictionary_suggestion(match)
      if match.l33t_entropy == 1
        "Predictable substitutions like '@' instead of 'a' don't help very much"
      elsif match.uppercase_entropy == 1
        "Capitalization doesn't help very much"
      else
        ""
      end
    end

  end
end
