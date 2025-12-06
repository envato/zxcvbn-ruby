# frozen_string_literal: true

module Zxcvbn
  class DictionaryRanker
    def self.rank_dictionaries(lists)
      lists.transform_values do |words|
        rank_dictionary(words)
      end
    end

    def self.rank_dictionary(words)
      words.each_with_index
           .with_object({}) do |(word, i), dictionary|
        dictionary[word.downcase] = i + 1
      end
    end
  end
end
