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

  describe '#sequence_entropy' do
    let(:match) { Zxcvbn::Match.new(:token => token, :ascending => true) }

    {'a' => 'abcdefg', '1' => '1234567'}.each do |first_char, token|
      context "when the first char is #{first_char}" do
        let(:token) { token }

        it 'returns the correct value' do
          entropy.sequence_entropy(match).should eq 3.807354922057604
        end
      end
    end

    context 'when the first character is a digit' do
      let(:token) { '23456' }

      it 'returns the correct value' do
        entropy.sequence_entropy(match).should eq 5.643856189774725
      end
    end

    context 'when the first character is a lowercase letter' do
      let(:token) { 'bcdef' }

      it 'returns the correct value' do
        entropy.sequence_entropy(match).should eq 7.022367813028454
      end
    end

    context 'when the first character is an uppercase letter' do
      let(:token) { 'BCDEF' }

      it 'returns the correct value' do
        entropy.sequence_entropy(match).should eq 8.022367813028454
      end
    end

    context 'when the match is ascending' do
      before { match.ascending = false }
      let(:token) { 'bcdef' }

      it 'returns the correct value' do
        entropy.sequence_entropy(match).should eq 8.022367813028454
      end
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