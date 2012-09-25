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

  describe '#date_entropy' do
    context 'with a two digit year' do
      it 'returns the correct value' do
        match = Zxcvbn::Match.new(:year => 98)
        entropy.date_entropy(match).should eq 15.183015000882756
      end
    end

    context 'with a four digit year' do
      it 'returns the correct value' do
        match = Zxcvbn::Match.new(:year => 2012)
        entropy.date_entropy(match).should eq 15.433976574415976
      end
    end

    context 'with a separator' do
      it 'returns the correct value' do
        match = Zxcvbn::Match.new(:year => 2012, :separator => '/')
        entropy.date_entropy(match).should eq 17.433976574415976
      end
    end
  end
end