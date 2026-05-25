# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Match do
  describe '#initialize' do
    it 'creates a match with keyword arguments' do
      match = described_class.new(
        pattern: 'dictionary',
        i: 0,
        j: 5,
        token: 'password'
      )

      expect(match.pattern).to eq('dictionary')
      expect(match.i).to eq(0)
      expect(match.j).to eq(5)
      expect(match.token).to eq('password')
    end

    it 'accepts all documented attributes' do
      match = described_class.new(
        pattern: 'dictionary',
        i: 0,
        j: 7,
        token: 'p@ssw0rd',
        matched_word: 'password',
        rank: 100,
        dictionary_name: 'english_wikipedia',
        reversed: false,
        l33t: true,
        sub: { '@' => 'a', '0' => 'o' },
        sub_display: '@ -> a, 0 -> o',
        sequence_name: nil,
        sequence_space: nil,
        ascending: nil,
        graph: nil,
        turns: nil,
        shifted_count: nil,
        year: nil,
        month: nil,
        day: nil,
        separator: nil
      )

      expect(match.pattern).to eq('dictionary')
      expect(match.matched_word).to eq('password')
      expect(match.l33t).to be true
      expect(match.sub).to eq({ '@' => 'a', '0' => 'o' })
    end

    it 'allows partial attribute initialisation' do
      match = described_class.new(pattern: 'repeat', token: 'aaa')

      expect(match.pattern).to eq('repeat')
      expect(match.token).to eq('aaa')
      expect(match.i).to be_nil
      expect(match.guesses).to be_nil
    end

    it 'creates empty match with no arguments' do
      match = described_class.new

      expect(match.pattern).to be_nil
      expect(match.token).to be_nil
    end
  end

  describe '#with' do
    it 'derives a new match with changed pattern' do
      match = described_class.new
      updated = match.with(pattern: 'spatial')
      expect(updated.pattern).to eq('spatial')
      expect(match.pattern).to be_nil
    end

    it 'derives a new match with changed position attributes' do
      match = described_class.new
      updated = match.with(i: 5, j: 10)
      expect(updated.i).to eq(5)
      expect(updated.j).to eq(10)
    end

    it 'derives a new match with changed dictionary attributes' do
      match = described_class.new
      updated = match.with(matched_word: 'test', rank: 500, dictionary_name: 'passwords')
      expect(updated.matched_word).to eq('test')
      expect(updated.rank).to eq(500)
      expect(updated.dictionary_name).to eq('passwords')
    end

    it 'derives a new match with changed l33t attributes' do
      match = described_class.new
      updated = match.with(l33t: true, sub: { '3' => 'e' }, sub_display: '3 -> e')
      expect(updated.l33t).to be true
      expect(updated.sub).to eq({ '3' => 'e' })
      expect(updated.sub_display).to eq('3 -> e')
    end

    it 'derives a new match with changed date attributes' do
      match = described_class.new
      updated = match.with(year: 2024, month: 12, day: 25, separator: '/')
      expect(updated.year).to eq(2024)
      expect(updated.month).to eq(12)
      expect(updated.day).to eq(25)
      expect(updated.separator).to eq('/')
    end

    it 'does not mutate the original' do
      match = described_class.new(pattern: 'digits', token: 'abc')
      match.with(pattern: 'spatial')
      expect(match.pattern).to eq('digits')
    end
  end

  describe 'value object equality' do
    it 'is equal to another match with the same attributes' do
      a = described_class.new(pattern: 'digits', token: '123', i: 0, j: 2)
      b = described_class.new(pattern: 'digits', token: '123', i: 0, j: 2)
      expect(a).to eq(b)
    end

    it 'is not equal to a match with different attributes' do
      a = described_class.new(pattern: 'digits', token: '123')
      b = described_class.new(pattern: 'digits', token: '456')
      expect(a).not_to eq(b)
    end

    it 'is eql? to another match with the same attributes' do
      a = described_class.new(pattern: 'digits', token: '123', i: 0, j: 2)
      b = described_class.new(pattern: 'digits', token: '123', i: 0, j: 2)
      expect(a).to eql(b)
    end

    it 'produces the same hash for matches with the same attributes' do
      a = described_class.new(pattern: 'digits', token: '123', i: 0, j: 2)
      b = described_class.new(pattern: 'digits', token: '123', i: 0, j: 2)
      expect(a.hash).to eq(b.hash)
    end
  end

  describe 'immutability' do
    it 'is frozen' do
      expect(described_class.new(pattern: 'digits', token: '123')).to be_frozen
    end

    it 'does not respond to attribute setters' do
      match = described_class.new(pattern: 'digits', token: '123')
      expect(match).not_to respond_to(:pattern=)
    end
  end

  describe 'integration with matchers' do
    it 'works with dictionary matcher pattern' do
      match = described_class.new(
        matched_word: 'password',
        token: 'password',
        i: 0,
        j: 7,
        rank: 1,
        pattern: 'dictionary',
        dictionary_name: 'english_wikipedia'
      )

      expect(match.pattern).to eq('dictionary')
      expect(match.matched_word).to eq('password')
      expect(match.dictionary_name).to eq('english_wikipedia')
    end

    it 'works with spatial matcher pattern' do
      match = described_class.new(
        pattern: 'spatial',
        i: 0,
        j: 5,
        token: 'qwerty',
        graph: 'qwerty',
        turns: 1,
        shifted_count: 0
      )

      expect(match.pattern).to eq('spatial')
      expect(match.graph).to eq('qwerty')
      expect(match.turns).to eq(1)
    end

    it 'works with repeat matcher pattern' do
      match = described_class.new(
        pattern: 'repeat',
        i: 0,
        j: 3,
        token: 'aaaa',
        base_token: 'a',
        repeat_count: 4
      )

      expect(match.pattern).to eq('repeat')
      expect(match.base_token).to eq('a')
      expect(match.repeat_count).to eq(4)
    end

    it 'works with sequence matcher pattern' do
      match = described_class.new(
        pattern: 'sequence',
        i: 0,
        j: 6,
        token: 'abcdefg',
        sequence_name: 'lower',
        sequence_space: 26,
        ascending: true
      )

      expect(match.pattern).to eq('sequence')
      expect(match.sequence_name).to eq('lower')
      expect(match.ascending).to be true
    end

    it 'works with date matcher pattern' do
      match = described_class.new(
        pattern: 'date',
        i: 0,
        j: 9,
        token: '12/25/2024',
        year: 2024,
        month: 12,
        day: 25,
        separator: '/'
      )

      expect(match.pattern).to eq('date')
      expect(match.year).to eq(2024)
      expect(match.separator).to eq('/')
    end

    it 'works with year matcher pattern' do
      match = described_class.new(
        pattern: 'year',
        i: 0,
        j: 3,
        token: '2024'
      )

      expect(match.pattern).to eq('year')
      expect(match.token).to eq('2024')
    end
  end
end
