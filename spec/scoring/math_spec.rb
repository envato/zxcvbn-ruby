require 'spec_helper'

describe Zxcvbn::Math do
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
          (0..9).each do |digit|
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
end