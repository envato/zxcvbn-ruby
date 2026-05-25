# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::MatchBuilder do
  describe '#build' do
    it 'returns a Zxcvbn::Match' do
      builder = described_class.new(pattern: 'digits', token: '123', i: 0, j: 2)
      expect(builder.build).to be_a(Zxcvbn::Match)
    end

    it 'returns a frozen Match' do
      builder = described_class.new(pattern: 'spatial', token: 'qwerty')
      expect(builder.build).to be_frozen
    end

    it 'transfers all set attribute values to the Match' do
      builder = described_class.new(
        pattern: 'dictionary',
        i: 0,
        j: 7,
        token: 'p@ssw0rd',
        matched_word: 'password',
        rank: 42,
        dictionary_name: 'english_wikipedia',
        l33t: true,
        sub: { '@' => 'a', '0' => 'o' },
        sub_display: '@ -> a, 0 -> o',
        guesses: 100.0,
        guesses_log10: 2.0
      )
      match = builder.build

      expect(match.pattern).to eq('dictionary')
      expect(match.i).to eq(0)
      expect(match.j).to eq(7)
      expect(match.token).to eq('p@ssw0rd')
      expect(match.matched_word).to eq('password')
      expect(match.rank).to eq(42)
      expect(match.dictionary_name).to eq('english_wikipedia')
      expect(match.l33t).to be true
      expect(match.sub).to eq({ '@' => 'a', '0' => 'o' })
      expect(match.sub_display).to eq('@ -> a, 0 -> o')
      expect(match.guesses).to eq(100.0)
      expect(match.guesses_log10).to eq(2.0)
    end

    it 'preserves nil for unset attributes' do
      builder = described_class.new(pattern: 'repeat', token: 'aaa')
      match = builder.build

      expect(match.i).to be_nil
      expect(match.guesses).to be_nil
      expect(match.graph).to be_nil
    end

    it 'produces equal Matches when called twice on the same builder state' do
      builder = described_class.new(pattern: 'digits', token: '42', i: 3, j: 4)
      expect(builder.build).to eq(builder.build)
    end

    it 'reflects mutations made before the call' do
      builder = described_class.new(pattern: 'dictionary', token: 'pass', rank: 5)
      builder.guesses = 999.0
      builder.guesses_log10 = 3.0
      match = builder.build

      expect(match.guesses).to eq(999.0)
      expect(match.guesses_log10).to eq(3.0)
    end
  end

  describe 'mutability' do
    it 'allows attribute values to be changed after construction' do
      builder = described_class.new(pattern: 'dictionary', token: 'test')
      builder.guesses = 42.0
      builder.l33t = true
      expect(builder.guesses).to eq(42.0)
      expect(builder.l33t).to be true
    end
  end

  describe 'member parity with Match' do
    it 'has the same members as Match' do
      expect(described_class.members).to eq(Zxcvbn::Match.members)
    end
  end
end
