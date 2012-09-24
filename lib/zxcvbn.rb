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
require 'zxcvbn/omnimatch'
require 'zxcvbn/score'
require 'zxcvbn/scoring'
require 'pathname'
require 'json'

module Zxcvbn
  DATA_PATH = Pathname(File.expand_path('../../data', __FILE__))
  ADJACENCY_GRAPHS = YAML.load(DATA_PATH.join('adjacency_graphs.yaml').read)
  FREQUENCY_LISTS = YAML.load(DATA_PATH.join('frequency_lists.yaml').read)

  def zxcvbn(password)
  end

  def omnimatch(password)
    @omnimatch ||= Omnimatch.new
    @omnimatch.matches(password)
  end
end
