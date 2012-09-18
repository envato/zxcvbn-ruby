require 'zxcvbn/version'
require 'zxcvbn/match'
require 'zxcvbn/matching/dictionary'
require 'pathname'
require 'json'

module Zxcvbn
  DATA_PATH = Pathname(File.expand_path('../../data', __FILE__))

  ADJACENCY_GRAPHS = YAML.load(DATA_PATH.join('adjacency_graphs.yaml').read)
  FREQUENCY_LISTS = YAML.load(DATA_PATH.join('frequency_lists.yaml').read)

  def zxcvbn(password)
  end
end
