# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::DictionaryRanker do
  describe '.rank_dictionaries' do
    it 'ranks word lists' do
      result = Zxcvbn::DictionaryRanker.rank_dictionaries({ test: %w[ABC def],
                                                            test2: %w[def ABC] })
      expect(result[:test]).to eq({ 'abc' => 1, 'def' => 2 })
      expect(result[:test2]).to eq({ 'def' => 1, 'abc' => 2 })
    end
  end

  describe '.rank_dictionary' do
    it 'ranks a word list by frequency order' do
      result = Zxcvbn::DictionaryRanker.rank_dictionary(%w[ABC def])
      expect(result).to eq({ 'abc' => 1, 'def' => 2 })
    end

    context 'with a word whose downcased form is longer (İstanbul)' do
      subject(:ranked) { Zxcvbn::DictionaryRanker.rank_dictionary(['İstanbul']) }

      it 'keys the word under a length-preserving lowercase form' do
        expect(ranked).to eq({ 'istanbul' => 1 })
      end

      it 'keeps the key the same character length as the original word' do
        expect(ranked.keys.first.length).to eq('İstanbul'.length)
      end
    end
  end
end
