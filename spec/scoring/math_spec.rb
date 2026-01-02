# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Math do
  include Zxcvbn::Math

  def data
    Zxcvbn::Data.new
  end

  describe '#bruteforce_cardinality' do
    context 'when empty password' do
      it 'should return 0 if empty password' do
        expect(bruteforce_cardinality('')).to eql 0
      end
    end

    context 'when password is one character long' do
      context 'and a digit' do
        it 'should return 10' do
          10.times do |digit|
            expect(bruteforce_cardinality(digit.to_s)).to eql 10
          end
        end
      end

      context 'and an upper case character' do
        it 'should return 26' do
          ('A'..'Z').each do |character|
            expect(bruteforce_cardinality(character)).to eql 26
          end
        end
      end

      context 'and a lower case character' do
        it 'should return 26' do
          ('a'..'z').each do |character|
            expect(bruteforce_cardinality(character)).to eql 26
          end
        end
      end

      context 'and a symbol' do
        it 'should return 33' do
          %w|/ [ ` {|.each do |symbol|
            expect(bruteforce_cardinality(symbol)).to eql 33
          end
        end
      end
    end

    context 'when password is more than one character long' do
      context 'and only digits' do
        it 'should return 10' do
          expect(bruteforce_cardinality('123456789')).to eql 10
        end
      end

      context 'and only lowercase characters' do
        it 'should return 26' do
          expect(bruteforce_cardinality('password')).to eql 26
        end
      end

      context 'and only uppercase characters' do
        it 'should return 26' do
          expect(bruteforce_cardinality('PASSWORD')).to eql 26
        end
      end

      context 'and only symbols' do
        it 'should return 33' do
          expect(bruteforce_cardinality('/ [ ` {')).to eql 33
        end
      end

      context 'and a mixed of character types' do
        it 'should add up every character type cardinality' do
          expect(bruteforce_cardinality('p1SsWorD!')).to eql 95
        end
      end
    end
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

  describe '#lg' do
    it 'calculates log base 2 correctly' do
      expect(lg(1)).to eq 0.0
      expect(lg(2)).to eq 1.0
      expect(lg(4)).to eq 2.0
      expect(lg(8)).to eq 3.0
      expect(lg(16)).to eq 4.0
    end

    it 'handles non-power-of-2 values' do
      expect(lg(3)).to be_within(0.0001).of(1.5849625)
      expect(lg(10)).to be_within(0.0001).of(3.3219281)
      expect(lg(100)).to be_within(0.0001).of(6.6438562)
    end

    it 'handles decimal values' do
      expect(lg(0.5)).to eq(-1.0)
      expect(lg(0.25)).to eq(-2.0)
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
