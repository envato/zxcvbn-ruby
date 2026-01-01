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
        dictionary_name: 'english',
        reversed: false,
        l33t: true,
        sub: { '@' => 'a', '0' => 'o' },
        sub_display: '@ -> a, 0 -> o',
        l: 8,
        entropy: 10.5,
        base_entropy: 8.0,
        uppercase_entropy: 1.0,
        l33t_entropy: 1.5,
        repeated_char: nil,
        sequence_name: nil,
        sequence_space: nil,
        ascending: nil,
        graph: nil,
        turns: nil,
        shifted_count: nil,
        shiffted_count: nil,
        year: nil,
        month: nil,
        day: nil,
        separator: nil,
        cardinality: 26,
        offset: 0
      )

      expect(match.pattern).to eq('dictionary')
      expect(match.matched_word).to eq('password')
      expect(match.l33t).to be true
      expect(match.sub).to eq({ '@' => 'a', '0' => 'o' })
      expect(match.cardinality).to eq(26)
    end

    it 'allows partial attribute initialisation' do
      match = described_class.new(pattern: 'repeat', token: 'aaa')

      expect(match.pattern).to eq('repeat')
      expect(match.token).to eq('aaa')
      expect(match.i).to be_nil
      expect(match.entropy).to be_nil
    end

    it 'creates empty match with no arguments' do
      match = described_class.new

      expect(match.pattern).to be_nil
      expect(match.token).to be_nil
    end
  end

  describe 'attribute accessors' do
    let(:match) { described_class.new }

    it 'allows reading and writing pattern' do
      match.pattern = 'spatial'
      expect(match.pattern).to eq('spatial')
    end

    it 'allows reading and writing position attributes' do
      match.i = 5
      match.j = 10
      expect(match.i).to eq(5)
      expect(match.j).to eq(10)
    end

    it 'allows reading and writing token' do
      match.token = 'test123'
      expect(match.token).to eq('test123')
    end

    it 'allows reading and writing entropy values' do
      match.entropy = 12.5
      match.base_entropy = 10.0
      match.uppercase_entropy = 1.5
      match.l33t_entropy = 1.0

      expect(match.entropy).to eq(12.5)
      expect(match.base_entropy).to eq(10.0)
      expect(match.uppercase_entropy).to eq(1.5)
      expect(match.l33t_entropy).to eq(1.0)
    end

    it 'allows reading and writing dictionary attributes' do
      match.matched_word = 'test'
      match.rank = 500
      match.dictionary_name = 'passwords'

      expect(match.matched_word).to eq('test')
      expect(match.rank).to eq(500)
      expect(match.dictionary_name).to eq('passwords')
    end

    it 'allows reading and writing l33t attributes' do
      match.l33t = true
      match.sub = { '3' => 'e' }
      match.sub_display = '3 -> e'

      expect(match.l33t).to be true
      expect(match.sub).to eq({ '3' => 'e' })
      expect(match.sub_display).to eq('3 -> e')
    end

    it 'allows reading and writing repeat attributes' do
      match.repeated_char = 'a'
      expect(match.repeated_char).to eq('a')
    end

    it 'allows reading and writing sequence attributes' do
      match.sequence_name = 'lower'
      match.sequence_space = 26
      match.ascending = true

      expect(match.sequence_name).to eq('lower')
      expect(match.sequence_space).to eq(26)
      expect(match.ascending).to be true
    end

    it 'allows reading and writing spatial attributes' do
      match.graph = 'qwerty'
      match.turns = 3
      match.shifted_count = 2

      expect(match.graph).to eq('qwerty')
      expect(match.turns).to eq(3)
      expect(match.shifted_count).to eq(2)
    end

    it 'allows reading and writing date attributes' do
      match.year = 2024
      match.month = 12
      match.day = 25
      match.separator = '/'

      expect(match.year).to eq(2024)
      expect(match.month).to eq(12)
      expect(match.day).to eq(25)
      expect(match.separator).to eq('/')
    end

    it 'allows reading and writing other attributes' do
      match.cardinality = 36
      match.offset = 5
      match.reversed = true
      match.l = 10

      expect(match.cardinality).to eq(36)
      expect(match.offset).to eq(5)
      expect(match.reversed).to be true
      expect(match.l).to eq(10)
    end
  end

  describe '#to_hash' do
    it 'converts match to hash with all attributes' do
      match = described_class.new(
        pattern: 'dictionary',
        i: 0,
        j: 4,
        token: 'test',
        rank: 100
      )

      hash = match.to_hash

      expect(hash).to be_a(Hash)
      expect(hash['pattern']).to eq('dictionary')
      expect(hash['i']).to eq(0)
      expect(hash['j']).to eq(4)
      expect(hash['token']).to eq('test')
      expect(hash['rank']).to eq(100)
    end

    it 'only includes attributes that were set' do
      match = described_class.new(pattern: 'repeat', token: 'aaa')
      hash = match.to_hash

      expect(hash.keys).to contain_exactly('pattern', 'token')
      expect(hash['pattern']).to eq('repeat')
      expect(hash['token']).to eq('aaa')
    end

    it 'returns hash keys as strings' do
      match = described_class.new(pattern: 'spatial', token: 'qwerty')
      hash = match.to_hash

      hash.each_key do |key|
        expect(key).to be_a(String)
      end
    end

    it 'sorts keys alphabetically' do
      match = described_class.new(
        token: 'test',
        pattern: 'dictionary',
        i: 0,
        j: 3
      )

      hash = match.to_hash
      keys = hash.keys

      expect(keys).to eq(keys.sort)
    end

    it 'preserves complex attribute values' do
      sub_hash = { '@' => 'a', '0' => 'o' }
      match = described_class.new(
        l33t: true,
        sub: sub_hash
      )

      hash = match.to_hash

      expect(hash['l33t']).to be true
      expect(hash['sub']).to eq(sub_hash)
      expect(hash['sub']).to be(sub_hash) # Same object reference
    end
  end

  describe 'backward compatibility' do
    it 'maintains compatibility with OpenStruct-style usage' do
      # This test ensures the new implementation works like OpenStruct did
      match = described_class.new(pattern: 'test', token: 'password')

      # Should be able to read attributes
      expect(match.pattern).to eq('test')
      expect(match.token).to eq('password')

      # Should be able to write attributes
      match.entropy = 10.5
      expect(match.entropy).to eq(10.5)

      # Should convert to hash
      hash = match.to_hash
      expect(hash).to be_a(Hash)
      expect(hash['pattern']).to eq('test')
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
        dictionary_name: 'english'
      )

      expect(match.pattern).to eq('dictionary')
      expect(match.matched_word).to eq('password')
      expect(match.dictionary_name).to eq('english')
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
        repeated_char: 'a'
      )

      expect(match.pattern).to eq('repeat')
      expect(match.repeated_char).to eq('a')
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
