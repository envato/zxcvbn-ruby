require 'spec_helper'

describe Zxcvbn::Matchers::Sequences do
  let(:matcher) { subject }
  let(:matches) { matcher.matches('abcde87654') }

  it 'sets the pattern name' do
    expect(matches.all? { |m| m.pattern == 'sequence' }).to eql(true)
  end

  it 'finds the correct matches' do
    expect(matches.count).to eq(2)
    expect(matches[0].token).to eq 'abcde'
    expect(matches[1].token).to eq '87654'
  end

  it 'finds overlapping matches' do
    matches = matcher.matches('abcba')
    expect(matches.map(&:token)).to eq ['abc', 'cba']
  end
end
