require 'zxcvbn/version'
require 'zxcvbn/match'
require 'zxcvbn/matching/dictionary'
require 'pathname'
require 'json'

module Zxcvbn
  DATA_PATH = Pathname(File.expand_path('../../data', __FILE__))

  ADJACENCY_GRAPHS = JSON.parse(DATA_PATH.join('adjacency_graphs.json').read)
  FREQUENCY_LISTS = JSON.parse(DATA_PATH.join('frequency_lists.json').read)

  def zxcvbn(password)
  end
end
