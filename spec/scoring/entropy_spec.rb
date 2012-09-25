require 'spec_helper'

describe Zxcvbn::Scoring::Entropy do
  include Zxcvbn::Scoring::Math

  let(:entropy) {
    Class.new do
      include Zxcvbn::Scoring::Entropy
    end.new
  }

  describe '#repeat_entropy' do
    it 'returns the correct value' do
      match = Zxcvbn::Match.new(:token => '2222')
      entropy.repeat_entropy(match).should eq 5.321928094887363
    end
  end

  describe '#digits_entropy' do
    it 'returns the correct value' do
      match = Zxcvbn::Match.new(:token => '12345678')
      entropy.digits_entropy(match).should eq 26.5754247590989
    end
  end

  describe '#year_entropy' do
    it 'returns the correct value' do
      entropy.year_entropy(nil).should eq 6.894817763307944
    end
  end
end