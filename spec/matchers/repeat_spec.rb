require 'spec_helper'

describe Zxcvbn::Matchers::Repeat do
  let(:matcher) { subject }
  let(:matches) { matcher.matches('bbbbbtestingaaa') }

  it 'sets the pattern name' do
    expect(matches.all? { |m| m.pattern == 'repeat' }).to eql(true)
  end

  it 'finds the repeated patterns' do
    expect(matches.count).to eq 2
    expect(matches[0].token).to eq 'bbbbb'
    expect(matches[0].repeated_char).to eq 'b'
    expect(matches[1].token).to eq 'aaa'
    expect(matches[1].repeated_char).to eq 'a'
  end
end