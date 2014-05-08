# encoding: utf-8

module Zxcvbn
  class DictionaryRanker
    def self.rank_dictionaries(lists)
      dictionaries = {}
      lists.each do |dict_name, words|
        dictionaries[dict_name] = rank_dictionary(words)
      end
      dictionaries
    end

    def self.rank_dictionary(words)
      dictionary = {}
      i = 1
      words.each do |word|
        dictionary[word.to_s.downcase] = i
        i += 1
      end
      dictionary
    end
  end
end
