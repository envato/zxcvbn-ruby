require 'spec_helper'

describe Zxcvbn::Matchers::Sequences do
  let(:matcher) { subject }
  let(:matches) { matcher.matches('abcde87654') }

  it 'sets the pattern name' do
    matches.all? { |m| m.pattern == 'sequence' }.should be_true
  end

  it 'finds the correct matches' do
    matches.count.should == 2
    matches[0].token.should eq 'abcde'
    matches[1].token.should eq '87654'
  end
end