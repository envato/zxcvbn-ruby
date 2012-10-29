require 'spec_helper'

describe Zxcvbn::Matchers::Dictionary do
  let(:matcher) { described_class.new('english', dictionary) }
  let(:dictionary) { Zxcvbn::RANKED_DICTIONARIES['english'] }

  it 'finds all the matches' do
    matches = matcher.matches('whatisinit')
    matches.count.should == 14
    expected_matches = ['wha', 'what', 'ha', 'hat', 'a', 'at', 'tis', 'i', 'is',
                       'sin', 'i', 'in', 'i', 'it']
    matches.map(&:matched_word).should == expected_matches
  end
end