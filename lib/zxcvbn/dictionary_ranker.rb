module Zxcvbn
  class DictionaryRanker
    def self.rank_dictionaries(lists)
      lists.each_with_object({}) do |(dict_name, words), dictionaries|
        dictionaries[dict_name] = rank_dictionary(words)
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
