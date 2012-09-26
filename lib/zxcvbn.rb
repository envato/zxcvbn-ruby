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
require 'zxcvbn/omnimatch'
require 'zxcvbn/math'
require 'zxcvbn/entropy'
require 'zxcvbn/crack_time'
require 'zxcvbn/score'
require 'zxcvbn/scorer'
require 'zxcvbn/password_strength'
require 'pathname'

module Zxcvbn
  DATA_PATH = Pathname(File.expand_path('../../data', __FILE__))
  ADJACENCY_GRAPHS = YAML.load(DATA_PATH.join('adjacency_graphs.yaml').read)
  FREQUENCY_LISTS = YAML.load(DATA_PATH.join('frequency_lists.yaml').read)

  def zxcvbn(password)
    @zxcvbn ||= PasswordStrength.new
    @zxcvbn.test(password)
  end
end
