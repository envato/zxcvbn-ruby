require 'spec_helper'

describe Zxcvbn::Matchers::Year do
  let(:matcher) { subject }
  let(:matches) { matcher.matches('testing1998') }

  it 'sets the pattern name' do
    expect(matches.all? { |m| m.pattern == 'year' }).to eql(true)
  end

  it 'finds the correct matches' do
    expect(matches.count).to eq(1)
    expect(matches[0].token).to eq '1998'
  end
end