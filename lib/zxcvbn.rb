require 'json'
require 'pathname'

require 'zxcvbn/version'
require 'zxcvbn/match'
require 'zxcvbn/matchers/regex_helpers'
require 'zxcvbn/matchers/dictionary'
require 'zxcvbn/matchers/l33t'
require 'zxcvbn/matchers/spatial'
require 'zxcvbn/matchers/sequences'
require 'zxcvbn/matchers/repeat'
require 'zxcvbn/matchers/digits'
require 'zxcvbn/matchers/year'
require 'zxcvbn/matchers/date'
require 'zxcvbn/dictionary_ranker'
require 'zxcvbn/omnimatch'
require 'zxcvbn/math'
require 'zxcvbn/entropy'
require 'zxcvbn/crack_time'
require 'zxcvbn/score'
require 'zxcvbn/scorer'
require 'zxcvbn/password_strength'

module Zxcvbn
  extend self

  DATA_PATH = Pathname(File.expand_path('../../data', __FILE__))
  ADJACENCY_GRAPHS = JSON.load(DATA_PATH.join('adjacency_graphs.json').read)
  FREQUENCY_LISTS_PATH = DATA_PATH.join("frequency_lists")
  FREQUENCY_LISTS = {
    "english":      FREQUENCY_LISTS_PATH.join("english.txt").read.split,
    "female_names": FREQUENCY_LISTS_PATH.join("female_names.txt").read.split,
    "male_names":   FREQUENCY_LISTS_PATH.join("male_names.txt").read.split,
    "passwords":    FREQUENCY_LISTS_PATH.join("passwords.txt").read.split,
    "surnames":     FREQUENCY_LISTS_PATH.join("surnames.txt").read.split
  }
  RANKED_DICTIONARIES = DictionaryRanker.rank_dictionaries(FREQUENCY_LISTS)

  def test(password, user_inputs = [])
    zxcvbn = PasswordStrength.new
    zxcvbn.test(password, user_inputs)
  end

  def add_word_list(name, list)
    RANKED_DICTIONARIES[name] = DictionaryRanker.rank_dictionary(list)
  end
end
