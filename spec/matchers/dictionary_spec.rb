require 'spec_helper'

describe Zxcvbn::Matchers::Dictionary do
  let(:matcher) { described_class.new('english', dictionary) }
  let(:dictionary) { Zxcvbn::Data.new.ranked_dictionaries['english'] }

  it 'finds all the matches' do
    matches = matcher.matches('whatisinit')
    expect(matches.count).to eq(14)
    expected_matches = ['wha', 'what', 'ha', 'hat', 'a', 'at', 'tis', 'i', 'is',
                       'sin', 'i', 'in', 'i', 'it']
    expect(matches.map(&:matched_word)).to eq(expected_matches)
  end

  it 'matches uppercase' do
    matcher = described_class.new('user_inputs', Zxcvbn::DictionaryRanker.rank_dictionary(['test','AB10CD']))
    expect(matcher.matches('AB10CD')).not_to be_empty
  end
end