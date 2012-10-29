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
  FREQUENCY_LISTS = YAML.load(DATA_PATH.join('frequency_lists.yaml').read)
  RANKED_DICTIONARIES = DictionaryRanker.rank_dictionaries(FREQUENCY_LISTS)

  def test(password, user_inputs = [])
    @zxcvbn = PasswordStrength.new
    @zxcvbn.test(password, user_inputs)
  end

  def add_word_list(name, list)
    RANKED_DICTIONARIES[name] = DictionaryRanker.rank_dictionary(list)
  end
end
