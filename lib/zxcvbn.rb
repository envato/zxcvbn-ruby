require 'zxcvbn/version'
require 'zxcvbn/match'
require 'zxcvbn/matching/regex_helpers'
require 'zxcvbn/matching/dictionary'
require 'zxcvbn/matching/l33t'
require 'zxcvbn/matching/spatial'
require 'zxcvbn/matching/sequences'
require 'zxcvbn/matching/repeat'
require 'zxcvbn/matching/digits'
require 'zxcvbn/matching/year'
require 'zxcvbn/matching/date'
require 'pathname'
require 'json'

module Zxcvbn
  DATA_PATH = Pathname(File.expand_path('../../data', __FILE__))

  ADJACENCY_GRAPHS = YAML.load(DATA_PATH.join('adjacency_graphs.yaml').read)
  FREQUENCY_LISTS = YAML.load(DATA_PATH.join('frequency_lists.yaml').read)

  RANKED_DICTIONARIES = {}

  def self.build_ranked_dictionaries
    FREQUENCY_LISTS.each do |dict_name, words|
      RANKED_DICTIONARIES[dict_name] = build_ranked_dictionary(words)
    end
  end

  def self.build_ranked_dictionary(words)
    {}.tap do |result|
      i = 1
      words.each do |word|
        result[word] = i
        i += 1
      end
    end
  end

  def zxcvbn(password)
  end

  def omnimatch(password)
    matchers = []
    dictionary_matchers = RANKED_DICTIONARIES.map do |name, dictionary|
      Matching::Dictionary.new(name, dictionary)
    end
    l33t_matcher = Matching::L33t.new(dictionary_matchers)
    matchers += dictionary_matchers
    matchers << l33t_matcher << Matching::Spatial.new(ADJACENCY_GRAPHS) << Matching::Digits.new << Matching::Repeat.new << Matching::Sequences.new << Matching::Year.new << Matching::Date.new
    result = []
    matchers.each do |matcher|
      result += matcher.matches(password)
    end
    result.flatten
  end
end
