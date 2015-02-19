require 'spec_helper'

describe Zxcvbn::Matchers::Digits do
  let(:matcher) { subject }
  let(:matches) { matcher.matches('testing1239xx9712') }

  it 'sets the pattern name' do
    matches.all? { |m| m.pattern == 'digits' }.should eql(true)
  end

  it 'finds the correct matches' do
    matches.count.should == 2
    matches[0].token.should eq '1239'
  end
end