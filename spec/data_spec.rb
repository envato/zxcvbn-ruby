# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Data do
  let(:data) { described_class.new }

  describe '#initialize' do
    it 'loads ranked dictionaries' do
      expect(data.ranked_dictionaries).to be_a(Hash)
      expect(data.ranked_dictionaries).not_to be_empty
    end

    it 'loads all expected dictionaries' do
      expect(data.ranked_dictionaries.keys).to include('english', 'female_names', 'male_names', 'passwords', 'surnames')
    end

    it 'loads adjacency graphs' do
      expect(data.adjacency_graphs).to be_a(Hash)
      expect(data.adjacency_graphs).not_to be_empty
    end

    it 'loads expected adjacency graphs' do
      expect(data.adjacency_graphs.keys).to include('qwerty', 'dvorak', 'keypad', 'mac_keypad')
    end

    it 'builds dictionary tries' do
      expect(data.dictionary_tries).to be_a(Hash)
      expect(data.dictionary_tries).not_to be_empty
    end

    it 'builds tries for all dictionaries' do
      expect(data.dictionary_tries.keys).to match_array(data.ranked_dictionaries.keys)
    end

    it 'creates Trie objects' do
      data.dictionary_tries.each_value do |trie|
        expect(trie).to be_a(Zxcvbn::Trie)
      end
    end

    it 'computes graph statistics' do
      expect(data.graph_stats).to be_a(Hash)
      expect(data.graph_stats).not_to be_empty
    end

    it 'computes stats for all graphs' do
      expect(data.graph_stats.keys).to match_array(data.adjacency_graphs.keys)
    end

    it 'includes average_degree in graph stats' do
      data.graph_stats.each_value do |stats|
        expect(stats).to have_key(:average_degree)
        expect(stats[:average_degree]).to be_a(Float)
        expect(stats[:average_degree]).to be > 0
      end
    end

    it 'includes starting_positions in graph stats' do
      data.graph_stats.each_value do |stats|
        expect(stats).to have_key(:starting_positions)
        expect(stats[:starting_positions]).to be_a(Integer)
        expect(stats[:starting_positions]).to be > 0
      end
    end
  end

  describe '#ranked_dictionaries' do
    it 'returns dictionaries with word rankings' do
      dict = data.ranked_dictionaries['english']
      expect(dict).to be_a(Hash)
      expect(dict.values.first).to be_a(Integer)
    end

    it 'ranks common words lower (more frequent)' do
      dict = data.ranked_dictionaries['passwords']
      # Common passwords should have low rank numbers
      expect(dict['password']).to be_a(Integer)
      expect(dict['password']).to be < 100
    end
  end

  describe '#add_word_list' do
    it 'adds a custom dictionary' do
      data.add_word_list('custom', %w[foo bar baz])
      expect(data.ranked_dictionaries).to have_key('custom')
    end

    it 'ranks the custom dictionary' do
      data.add_word_list('custom', %w[foo bar baz])
      dict = data.ranked_dictionaries['custom']
      expect(dict['foo']).to be_a(Integer)
      expect(dict['bar']).to be_a(Integer)
      expect(dict['baz']).to be_a(Integer)
    end

    it 'builds a trie for the custom dictionary' do
      data.add_word_list('custom', %w[foo bar baz])
      expect(data.dictionary_tries).to have_key('custom')
      expect(data.dictionary_tries['custom']).to be_a(Zxcvbn::Trie)
    end

    it 'makes custom words searchable via trie' do
      data.add_word_list('custom', %w[test])
      trie = data.dictionary_tries['custom']
      results = trie.search_prefixes('testing', 0)
      expect(results).not_to be_empty
      expect(results.first[0]).to eq('test')
    end

    it 'handles empty word lists' do
      data.add_word_list('empty', [])
      expect(data.ranked_dictionaries['empty']).to be_empty
    end
  end

  describe '#graph_stats' do
    it 'has correct values for qwerty keyboard' do
      stats = data.graph_stats['qwerty']
      expect(stats[:average_degree]).to be_within(0.01).of(4.6)
      expect(stats[:starting_positions]).to eq(94)
    end

    it 'has correct values for keypad' do
      stats = data.graph_stats['keypad']
      expect(stats[:average_degree]).to be_within(0.01).of(5.07)
      expect(stats[:starting_positions]).to eq(15)
    end
  end
end
