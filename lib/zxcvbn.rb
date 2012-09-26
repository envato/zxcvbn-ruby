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
require 'zxcvbn/scoring/math'
require 'zxcvbn/scoring/entropy'
require 'zxcvbn/scoring/crack_time'
require 'zxcvbn/score'
require 'zxcvbn/scoring'
require 'pathname'
require 'json'
require 'benchmark'

module Zxcvbn
  DATA_PATH = Pathname(File.expand_path('../../data', __FILE__))
  ADJACENCY_GRAPHS = YAML.load(DATA_PATH.join('adjacency_graphs.yaml').read)
  FREQUENCY_LISTS = YAML.load(DATA_PATH.join('frequency_lists.yaml').read)

  def zxcvbn(password)
    result = nil
    calc_time = Benchmark.realtime do
      matches = omnimatch(password)
      result = Scoring.new(password, matches).minimum_entropy_match_sequence
    end
    result.calc_time = calc_time
    result
  end

  def omnimatch(password)
    @omnimatch ||= Omnimatch.new
    @omnimatch.matches(password)
  end
end
