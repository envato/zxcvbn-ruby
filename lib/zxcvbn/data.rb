require 'json'
require 'zxcvbn/dictionary_ranker'

module Zxcvbn
  class Data
    def initialize
      @ranked_dictionaries = DictionaryRanker.rank_dictionaries(
        "english" =>      read_word_list("english.txt"),
        "female_names" => read_word_list("female_names.txt"),
        "male_names" =>   read_word_list("male_names.txt"),
        "passwords" =>    read_word_list("passwords.txt"),
        "surnames" =>     read_word_list("surnames.txt")
      )
      @adjacency_graphs = JSON.load(DATA_PATH.join('adjacency_graphs.json').read)
    end

    attr_reader :ranked_dictionaries, :adjacency_graphs

    def add_word_list(name, list)
      @ranked_dictionaries[name] = DictionaryRanker.rank_dictionary(list)
    end

    private

    def read_word_list(file)
      DATA_PATH.join("frequency_lists", file).read.split
    end
  end
end
