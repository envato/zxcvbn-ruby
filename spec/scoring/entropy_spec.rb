require 'spec_helper'

describe Zxcvbn::Scoring::Entropy do
  include Zxcvbn::Scoring::Math

  let(:entropy) {
    Class.new do
      include Zxcvbn::Scoring::Entropy
    end.new
  }

  describe '#digits_entropy' do
    it 'returns a base 2 log of 10 to the power of the token length' do
      match = Zxcvbn::Match.new(:token => '12345678')
      entropy.digits_entropy(match).should eq lg(10 ** match.token.length)
    end
  end

  describe '#year_entropy' do
    it 'returns a base 2 log of the number of possible years' do
      entropy.year_entropy(nil).should eq lg(Zxcvbn::Scoring::Entropy::NUM_YEARS)
    end
  end
end