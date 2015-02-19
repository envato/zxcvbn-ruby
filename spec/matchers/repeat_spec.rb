require 'spec_helper'

describe Zxcvbn::Matchers::Repeat do
  let(:matcher) { subject }
  let(:matches) { matcher.matches('bbbbbtestingaaa') }

  it 'sets the pattern name' do
    matches.all? { |m| m.pattern == 'repeat' }.should eql(true)
  end

  it 'finds the repeated patterns' do
    matches.count.should eq 2
    matches[0].token.should eq 'bbbbb'
    matches[0].repeated_char.should eq 'b'
    matches[1].token.should eq 'aaa'
    matches[1].repeated_char.should eq 'a'
  end
end