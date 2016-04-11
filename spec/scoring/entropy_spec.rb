require 'spec_helper'

describe Zxcvbn::Entropy do
  include Zxcvbn::Math

  let(:entropy) {
    Class.new do
      include Zxcvbn::Entropy
      def data
        Zxcvbn::Data.new
      end
    end.new
  }

  describe '#repeat_entropy' do
    it 'returns the correct value' do
      match = Zxcvbn::Match.new(:token => '2222')
      expect(entropy.repeat_entropy(match)).to eq 5.321928094887363
    end
  end

  describe '#sequence_entropy' do
    let(:match) { Zxcvbn::Match.new(:token => token, :ascending => true) }

    {'a' => 'abcdefg', '1' => '1234567'}.each do |first_char, token|
      context "when the first char is #{first_char}" do
        let(:token) { token }

        it 'returns the correct value' do
          expect(entropy.sequence_entropy(match)).to eq 3.807354922057604
        end
      end
    end

    context 'when the first character is a digit' do
      let(:token) { '23456' }

      it 'returns the correct value' do
        expect(entropy.sequence_entropy(match)).to eq 5.643856189774725
      end
    end

    context 'when the first character is a lowercase letter' do
      let(:token) { 'bcdef' }

      it 'returns the correct value' do
        expect(entropy.sequence_entropy(match)).to eq 7.022367813028454
      end
    end

    context 'when the first character is an uppercase letter' do
      let(:token) { 'BCDEF' }

      it 'returns the correct value' do
        expect(entropy.sequence_entropy(match)).to eq 8.022367813028454
      end
    end

    context 'when the match is ascending' do
      before { match.ascending = false }
      let(:token) { 'bcdef' }

      it 'returns the correct value' do
        expect(entropy.sequence_entropy(match)).to eq 8.022367813028454
      end
    end
  end

  describe '#digits_entropy' do
    it 'returns the correct value' do
      match = Zxcvbn::Match.new(:token => '12345678')
      expect(entropy.digits_entropy(match)).to eq 26.5754247590989
    end
  end

  describe '#year_entropy' do
    it 'returns the correct value' do
      expect(entropy.year_entropy(nil)).to eq 6.894817763307944
    end
  end

  describe '#date_entropy' do
    context 'with a two digit year' do
      it 'returns the correct value' do
        match = Zxcvbn::Match.new(:year => 98)
        expect(entropy.date_entropy(match)).to eq 15.183015000882756
      end
    end

    context 'with a four digit year' do
      it 'returns the correct value' do
        match = Zxcvbn::Match.new(:year => 2012)
        expect(entropy.date_entropy(match)).to eq 15.433976574415976
      end
    end

    context 'with a separator' do
      it 'returns the correct value' do
        match = Zxcvbn::Match.new(:year => 2012, :separator => '/')
        expect(entropy.date_entropy(match)).to eq 17.433976574415976
      end
    end
  end

  describe '#dictionary_entropy' do
    let(:match) { Zxcvbn::Match.new(:token => token, :rank => rank, :l33t => l33t, :sub => sub) }
    let(:l33t)  { false }
    let(:sub)   { {} }
    let(:calculated_entropy) { entropy.dictionary_entropy(match) }

    context 'a simple dictionary word, all lower case and no l33t subs' do
      let(:token) { 'you' }
      let(:rank)  { 1 }

      specify { expect(calculated_entropy).to eq 0 }
    end

    context 'with all upper case characters' do
      let(:token) { 'YOU' }
      let(:rank)  { 1 }

      specify { expect(calculated_entropy).to eq 1 }
    end

    context 'starting with uppercase' do
      let(:token) { 'You' }
      let(:rank)  { 1 }

      specify { expect(calculated_entropy).to eq 1 }
    end

    context 'starting with uppercase' do
      let(:token) { 'yoU' }
      let(:rank)  { 1 }

      specify { expect(calculated_entropy).to eq 1 }
    end

    context 'mixed upper and lower' do
      let(:token) { 'tEsTiNg' }
      let(:rank)  { 1 }

      specify { expect(calculated_entropy).to eq 6 }
    end

    context 'starting with digits' do
      let(:token) { '12345' }
      let(:rank)  { 1 }

      specify { expect(calculated_entropy).to eq 0 }
    end

    context 'extra l33t entropy' do
      let(:token) { 'p3rs0n' }
      let(:rank)  { 1 }
      let(:l33t)  { true }
      let(:sub)   { {'3' => 'e', '0' => 'o'} }

      specify { expect(calculated_entropy).to eq 1 }
    end
  end

  describe '#spatial_entropy' do
    let(:match) { Zxcvbn::Match.new(:token => '123wsclf', :turns => 1) }

    context 'when keyboard is qwerty' do
      it 'should return the correct entropy' do
        match.graph = 'qwerty'

        expect(entropy.spatial_entropy(match)).to eql 11.562242424221074
      end
    end

    context 'when keyboard is dvorak' do
      it 'should return the correct entropy' do
        match.graph = 'dvorak'

        expect(entropy.spatial_entropy(match)).to eql 11.562242424221074
      end
    end

    context 'when keyboard is not qwerty or dvorak' do
      it 'should return the correct entropy' do
        match.graph = 'keypad'

        expect(entropy.spatial_entropy(match)).to eql 9.05528243550119
      end
    end

    context 'when match includes several turns' do
      it 'should return the correct entropy' do
        match.turns = 5

        expect(entropy.spatial_entropy(match)).to eql 21.761397858718993
      end
    end

    context 'when match includes shifted count' do
      it 'should return the correct entropy' do
        match.shiffted_count = 5

        expect(entropy.spatial_entropy(match)).to eql 9.05528243550119
      end
    end

    context 'when match includes shifted count and several turns' do
      it 'should return the correct entropy' do
        match.shiffted_count = 5
        match.turns          = 5

        expect(entropy.spatial_entropy(match)).to eql 21.761397858718993
      end
    end
  end

end