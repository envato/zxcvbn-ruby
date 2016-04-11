require 'spec_helper'

describe Zxcvbn::DictionaryRanker do
  describe '.rank_dictionaries' do
    it 'ranks word lists' do
      result = Zxcvbn::DictionaryRanker.rank_dictionaries({:test => ['ABC', 'def'],
                                                           :test2 => ['def', 'ABC']})
      expect(result[:test]).to eq({'abc' => 1, 'def' => 2})
      expect(result[:test2]).to eq({'def' => 1, 'abc' => 2})
    end
  end
end
