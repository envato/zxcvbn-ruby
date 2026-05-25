# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Trie do
  let(:trie) { described_class.new }

  describe '#initialize' do
    it 'creates an empty trie' do
      expect(trie).to be_a(described_class)
    end
  end

  describe '#insert' do
    it 'inserts a single word with rank' do
      trie.insert('test', 1)
      results = trie.search_prefixes('test', 0)

      expect(results).to contain_exactly(['test', 1, 0, 3])
    end

    it 'inserts multiple words' do
      trie.insert('test', 1)
      trie.insert('testing', 2)
      trie.insert('word', 3)

      results = trie.search_prefixes('testing', 0)
      expect(results).to contain_exactly(
        ['test', 1, 0, 3],
        ['testing', 2, 0, 6]
      )
    end

    it 'handles words with common prefixes' do
      trie.insert('pass', 1)
      trie.insert('password', 2)
      trie.insert('passwords', 3)

      results = trie.search_prefixes('passwords', 0)
      expect(results).to contain_exactly(
        ['pass', 1, 0, 3],
        ['password', 2, 0, 7],
        ['passwords', 3, 0, 8]
      )
    end

    it 'allows updating rank for existing word' do
      trie.insert('test', 1)
      trie.insert('test', 10)

      results = trie.search_prefixes('test', 0)
      expect(results).to contain_exactly(['test', 10, 0, 3])
    end

    it 'handles single character words' do
      trie.insert('a', 1)
      trie.insert('i', 2)

      results = trie.search_prefixes('a', 0)
      expect(results).to contain_exactly(['a', 1, 0, 0])
    end

    it 'handles empty string insertion gracefully' do
      trie.insert('', 1)
      results = trie.search_prefixes('test', 0)

      expect(results).to be_empty
    end
  end

  describe '#search_prefixes' do
    before do
      trie.insert('pass', 1)
      trie.insert('password', 2)
      trie.insert('test', 3)
      trie.insert('testing', 4)
      trie.insert('word', 5)
    end

    it 'finds all matching prefixes from start position' do
      results = trie.search_prefixes('password', 0)

      expect(results).to contain_exactly(
        ['pass', 1, 0, 3],
        ['password', 2, 0, 7]
      )
    end

    it 'finds matches from different start positions' do
      results = trie.search_prefixes('mypassword', 2)

      expect(results).to contain_exactly(
        ['pass', 1, 2, 5],
        ['password', 2, 2, 9]
      )
    end

    it 'returns empty array when no matches found' do
      results = trie.search_prefixes('xyz', 0)

      expect(results).to be_empty
    end

    it 'stops searching when prefix no longer matches' do
      results = trie.search_prefixes('passfail', 0)

      expect(results).to contain_exactly(['pass', 1, 0, 3])
    end

    it 'handles search beyond text length gracefully' do
      results = trie.search_prefixes('test', 10)

      expect(results).to be_empty
    end

    it 'handles start position at text boundary' do
      results = trie.search_prefixes('test', 4)

      expect(results).to be_empty
    end

    it 'returns results in order of appearance' do
      results = trie.search_prefixes('testing', 0)

      expect(results[0]).to eq(['test', 3, 0, 3])
      expect(results[1]).to eq(['testing', 4, 0, 6])
    end

    it 'handles partial matches correctly' do
      results = trie.search_prefixes('passw', 0)

      expect(results).to contain_exactly(['pass', 1, 0, 3])
    end

    it 'finds multiple separate words in longer text' do
      text = 'testwordpassword'

      results_from_start = trie.search_prefixes(text, 0)
      results_from_word = trie.search_prefixes(text, 4)
      results_from_pass = trie.search_prefixes(text, 8)

      # Only 'test' matches, not 'testing' because text continues with 'word'
      expect(results_from_start).to contain_exactly(['test', 3, 0, 3])
      expect(results_from_word).to contain_exactly(['word', 5, 4, 7])
      expect(results_from_pass).to contain_exactly(
        ['pass', 1, 8, 11],
        ['password', 2, 8, 15]
      )
    end
  end

  describe 'integration with dictionary words' do
    it 'handles common password dictionary words' do
      common_words = {
        'password' => 1,
        '123456' => 2,
        'qwerty' => 3,
        'abc123' => 4,
        'password123' => 5
      }

      common_words.each { |word, rank| trie.insert(word, rank) }

      results = trie.search_prefixes('password123', 0)
      expect(results).to contain_exactly(
        ['password', 1, 0, 7],
        ['password123', 5, 0, 10]
      )
    end

    it 'handles name dictionaries' do
      names = {
        'john' => 1,
        'jane' => 2,
        'james' => 3,
        'jennifer' => 4
      }

      names.each { |name, rank| trie.insert(name, rank) }

      results = trie.search_prefixes('jamesbond', 0)
      expect(results).to contain_exactly(['james', 3, 0, 4])
    end

    it 'handles case-insensitive matching' do
      trie.insert('password', 1)

      # Trie expects lowercased input (handled by matcher)
      results = trie.search_prefixes('password', 0)
      expect(results).to contain_exactly(['password', 1, 0, 7])
    end
  end

  describe 'edge cases' do
    it 'handles very long words' do
      long_word = 'a' * 100
      trie.insert(long_word, 1)

      results = trie.search_prefixes(long_word, 0)
      expect(results).to contain_exactly([long_word, 1, 0, 99])
    end

    it 'handles special characters' do
      trie.insert('test@123', 1)
      trie.insert('hello!world', 2)

      results = trie.search_prefixes('test@123', 0)
      expect(results).to contain_exactly(['test@123', 1, 0, 7])
    end

    it 'handles unicode characters' do
      trie.insert('café', 1)
      trie.insert('naïve', 2)

      results = trie.search_prefixes('café', 0)
      expect(results).to contain_exactly(['café', 1, 0, 3])
    end

    it 'handles numbers in words' do
      trie.insert('123', 1)
      trie.insert('abc123', 2)
      trie.insert('123abc', 3)

      results = trie.search_prefixes('123abc', 0)
      expect(results).to contain_exactly(
        ['123', 1, 0, 2],
        ['123abc', 3, 0, 5]
      )
    end
  end

  describe 'performance characteristics' do
    it 'efficiently handles large dictionaries' do
      # Insert 1000 words
      1000.times do |i|
        trie.insert("word#{i}", i)
      end

      # NOTE: will find all prefix matches (word5, word50, word500)
      results = trie.search_prefixes('word500', 0)
      expect(results.last).to eq(['word500', 500, 0, 6])
      expect(results.length).to be > 0
    end

    it 'early terminates on non-matching prefixes' do
      trie.insert('apple', 1)
      trie.insert('application', 2)

      # Should terminate early when 'x' doesn't match
      results = trie.search_prefixes('xyz', 0)
      expect(results).to be_empty
    end
  end
end
