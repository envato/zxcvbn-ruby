require 'spec_helper'

describe Zxcvbn::Matching::Year do
  let(:matcher) { subject }
  let(:matches) { matcher.matches('testing1998') }

  it 'sets the pattern name' do
    matches.all? { |m| m.pattern == 'year' }.should be_true
  end

  it 'finds the correct matches' do
    matches.count.should == 1
    matches[0].token.should eq '1998'
  end
end