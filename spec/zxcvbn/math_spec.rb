# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Math do
  include Zxcvbn::Math

  def data
    ZXCVBN_TEST_DATA
  end

  describe '#average_degree_for_graph' do
    context 'when keyboard is qwerty' do
      it 'returns the correct average degree over all keys' do
        expect(average_degree_for_graph('qwerty')).to eql 4.595744680851064
      end
    end

    context 'when keyboard is dvorak' do
      it 'returns the correct average degree over all keys' do
        expect(average_degree_for_graph('dvorak')).to eql 4.595744680851064
      end
    end

    context 'when keyboard is keypad' do
      it 'returns the correct average degree over all keys' do
        expect(average_degree_for_graph('keypad')).to eql 5.066666666666666
      end
    end

    context 'when keyboard is mac keypad' do
      it 'returns the correct average degree over all keys' do
        expect(average_degree_for_graph('mac_keypad')).to eql 5.25
      end
    end
  end

  describe '#starting_positions_for_graph' do
    context 'when keyboard is qwerty' do
      it 'returns the correct average degree over all keys' do
        expect(starting_positions_for_graph('qwerty')).to eql 94
      end
    end

    context 'when keyboard is dvorak' do
      it 'returns the correct average degree over all keys' do
        expect(starting_positions_for_graph('dvorak')).to eql 94
      end
    end

    context 'when keyboard is keypad' do
      it 'returns the correct average degree over all keys' do
        expect(starting_positions_for_graph('keypad')).to eql 15
      end
    end

    context 'when keyboard is mac keypad' do
      it 'returns the correct average degree over all keys' do
        expect(starting_positions_for_graph('mac_keypad')).to eql 16
      end
    end
  end

  describe '#nCk' do
    it 'returns 0 when k > n' do
      expect(nCk(5, 10)).to eq 0
      expect(nCk(0, 1)).to eq 0
    end

    it 'returns 1 when k is zero' do
      expect(nCk(0, 0)).to eq 1
      expect(nCk(5, 0)).to eq 1
      expect(nCk(100, 0)).to eq 1
    end

    it 'calculates combinations correctly' do
      expect(nCk(5, 1)).to eq 5
      expect(nCk(5, 2)).to eq 10
      expect(nCk(5, 3)).to eq 10
      expect(nCk(5, 4)).to eq 5
      expect(nCk(5, 5)).to eq 1
    end

    it 'handles larger values' do
      expect(nCk(10, 5)).to eq 252
      expect(nCk(20, 10)).to eq 184_756
      expect(nCk(52, 5)).to eq 2_598_960 # poker hands
    end

    it 'demonstrates symmetry property C(n,k) = C(n,n-k)' do
      expect(nCk(10, 3)).to eq nCk(10, 7)
      expect(nCk(20, 5)).to eq nCk(20, 15)
    end

    it 'handles edge cases' do
      expect(nCk(1, 1)).to eq 1
      expect(nCk(2, 1)).to eq 2
    end
  end
end
