require 'zxcvbn/entropy'
require 'zxcvbn/feedback'

module Zxcvbn
  class FeedbackGiver
    NAME_DICTIONARIES = %w[surnames male_names female_names].freeze

    DEFAULT_FEEDBACK = Feedback.new(
      suggestions: [
        'Use a few words, avoid common phrases',
        'No need for symbols, digits, or uppercase letters'
      ]
    ).freeze

    EMPTY_FEEDBACK = Feedback.new.freeze

    def self.get_feedback(score, sequence)
      # starting feedback
      return DEFAULT_FEEDBACK if sequence.length.zero?

      # no feedback if score is good or great.
      return EMPTY_FEEDBACK if score > 2

      # tie feedback to the longest match for longer sequences
      longest_match = sequence[0]
      for match in sequence[1..-1]
        longest_match = match if match.token.length > longest_match.token.length
      end

      feedback = get_match_feedback(longest_match, sequence.length == 1)
      extra_feedback = 'Add another word or two. Uncommon words are better.'

      if feedback.nil?
        feedback = Feedback.new(suggestions: [extra_feedback])
      else
        feedback.suggestions.unshift extra_feedback
      end

      feedback
    end

    def self.get_match_feedback(match, is_sole_match)
      case match.pattern
      when 'dictionary'
        get_dictionary_match_feedback match, is_sole_match

      when 'spatial'
        layout = match.graph.upcase
        warning = if match.turns == 1
                    'Straight rows of keys are easy to guess'
                  else
                    'Short keyboard patterns are easy to guess'
                  end

        Feedback.new(
          warning: warning,
          suggestions: [
            'Use a longer keyboard pattern with more turns'
          ]
        )

      when 'repeat'
        Feedback.new(
          warning: 'Repeats like "aaa" are easy to guess',
          suggestions: [
            'Avoid repeated words and characters'
          ]
        )

      when 'sequence'
        Feedback.new(
          warning: 'Sequences like abc or 6543 are easy to guess',
          suggestions: [
            'Avoid sequences'
          ]
        )

      when 'date'
        Feedback.new(
          warning: 'Dates are often easy to guess',
          suggestions: [
            'Avoid dates and years that are associated with you'
          ]
        )
      end
    end

    def self.get_dictionary_match_feedback(match, is_sole_match)
      warning = if match.dictionary_name == 'passwords'
                  if is_sole_match && !match.l33t && !match.reversed
                    if match.rank <= 10
                      'This is a top-10 common password'
                    elsif match.rank <= 100
                      'This is a top-100 common password'
                    else
                      'This is a very common password'
                    end
                  else
                    'This is similar to a commonly used password'
                  end
                elsif NAME_DICTIONARIES.include? match.dictionary_name
                  if is_sole_match
                    'Names and surnames by themselves are easy to guess'
                  else
                    'Common names and surnames are easy to guess'
                  end
                end

      suggestions = []
      word = match.token

      if word =~ Zxcvbn::Entropy::START_UPPER
        suggestions.push "Capitalization doesn't help very much"
      elsif word =~ Zxcvbn::Entropy::ALL_UPPER && word.downcase != word
        suggestions.push(
          'All-uppercase is almost as easy to guess as all-lowercase'
        )
      end

      if match.l33t
        suggestions.push(
          "Predictable substitutions like '@' instead of 'a' \
don't help very much"
        )
      end

      Feedback.new(
        warning: warning,
        suggestions: suggestions
      )
    end
  end
end
