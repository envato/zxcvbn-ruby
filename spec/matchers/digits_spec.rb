require 'spec_helper'

describe Zxcvbn::Matchers::Digits do
  let(:matcher) { subject }
  let(:matches) { matcher.matches('testing1239xx9712') }

  it 'sets the pattern name' do
    expect(matches.all? { |m| m.pattern == 'digits' }).to eql(true)
  end

  it 'finds the correct matches' do
    expect(matches.count).to eq(2)
    expect(matches[0].token).to eq '1239'
  end
end