# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Matchers::Dictionary do
  describe '#matches' do
    let(:matches) { matcher.matches(password) }
    let(:matched_words) { matches.map(&:matched_word) }

    context 'with Trie-based matching' do
      subject(:matcher) { described_class.new('test', dictionary, trie) }

      let(:dictionary) { { 'password' => 1, 'pass' => 2, 'word' => 3 } }
      let(:trie) do
        trie = Zxcvbn::Trie.new
        dictionary.each { |word, rank| trie.insert(word, rank) }
        trie
      end
      let(:password) { 'password123' }

      it 'finds all matching dictionary words using trie' do
        expect(matched_words).to match_array(%w[pass password word])
      end

      it 'creates matches with correct attributes' do
        pass_match = matches.find { |m| m.matched_word == 'pass' }

        expect(pass_match.i).to eq(0)
        expect(pass_match.j).to eq(3)
        expect(pass_match.token).to eq('pass')
        expect(pass_match.rank).to eq(2)
        expect(pass_match.pattern).to eq('dictionary')
        expect(pass_match.dictionary_name).to eq('test')
      end
    end

    context 'with hash-based matching (no trie)' do
      subject(:matcher) { described_class.new('test', dictionary, nil) }

      let(:dictionary) { { 'password' => 1, 'pass' => 2, 'word' => 3 } }
      let(:password) { 'password123' }

      it 'finds all matching dictionary words using hash lookup' do
        expect(matched_words).to match_array(%w[pass password word])
      end

      it 'creates matches with correct attributes' do
        pass_match = matches.find { |m| m.matched_word == 'pass' }

        expect(pass_match.i).to eq(0)
        expect(pass_match.j).to eq(3)
        expect(pass_match.token).to eq('pass')
        expect(pass_match.rank).to eq(2)
        expect(pass_match.pattern).to eq('dictionary')
        expect(pass_match.dictionary_name).to eq('test')
      end
    end

    context 'comparing trie and hash implementations' do
      let(:dictionary) { { 'test' => 1, 'testing' => 2, 'pass' => 3, 'password' => 4 } }
      let(:password) { 'testpassword' }

      let(:trie) do
        trie = Zxcvbn::Trie.new
        dictionary.each { |word, rank| trie.insert(word, rank) }
        trie
      end

      let(:matcher_with_trie) { described_class.new('test', dictionary, trie) }
      let(:matcher_without_trie) { described_class.new('test', dictionary, nil) }

      it 'produces identical results' do
        trie_results = matcher_with_trie.matches(password).map do |m|
          [m.matched_word, m.i, m.j, m.rank]
        end.sort

        hash_results = matcher_without_trie.matches(password).map do |m|
          [m.matched_word, m.i, m.j, m.rank]
        end.sort

        expect(trie_results).to eq(hash_results)
      end
    end

    context 'Given a dictionary of English words' do
      subject(:matcher) { described_class.new('Test dictionary', dictionary) }

      let(:dictionary) { Zxcvbn::Data.new.ranked_dictionaries['english'] }
      let(:password) { 'whatisinit' }

      it 'finds all the matches' do
        expect(matched_words).to match_array %w[wha what ha hat a at tis i is sin i in i it]
      end
    end

    context 'Given a custom dictionary' do
      subject(:matcher) { described_class.new('Test dictionary', dictionary) }

      let(:dictionary) { Zxcvbn::DictionaryRanker.rank_dictionary(%w[test AB10CD]) }
      let(:password) { 'AB10CD' }

      it 'matches uppercase passwords with normalised dictionary entries' do
        expect(matched_words).to match_array(%w[ab10cd])
      end
    end
  end
end
