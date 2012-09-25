require 'spec_helper'

describe Zxcvbn::Scoring::Entropy do
  include Zxcvbn::Scoring::Math

  let(:entropy) {
    Class.new do
      include Zxcvbn::Scoring::Entropy
    end.new
  }

  describe '#digits_entropy' do
    it 'behaves the same as the js version' do
      match = Zxcvbn::Match.new(:token => '12345678')
      entropy.digits_entropy(match).should eq lg(10 ** match.token.length)
    end
  end

  describe '#year_entropy' do
    it 'behaves the same as the js version' do
      entropy.year_entropy(nil).should eq lg(Zxcvbn::Scoring::Entropy::NUM_YEARS)
    end
  end
end