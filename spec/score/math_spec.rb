require 'spec_helper'

describe Zxcvbn::Score do
  subject { described_class.new }

  describe '#bruteforce_cardinality' do
    context 'when empty password' do
      it 'should return 0 if empty password' do
        subject.bruteforce_cardinality('').should eql 0
      end
    end

    context 'when password is one character long' do
      context 'and a digit' do
        it 'should return 10' do
          (0..9).each do |digit|
            subject.bruteforce_cardinality(digit.to_s).should eql 10
          end
        end
      end

      context 'and an upper case character' do
        it 'should return 26' do
          ('A'..'Z').each do |character|
            subject.bruteforce_cardinality(character).should eql 26
          end
        end
      end

      context 'and a lower case character' do
        it 'should return 26' do
          ('a'..'z').each do |character|
            subject.bruteforce_cardinality(character).should eql 26
          end
        end
      end

      context 'and a symbol' do
        it 'should return 33' do
          %w|/ [ ` {|.each do |symbol|
            subject.bruteforce_cardinality(symbol).should eql 33
          end
        end
      end
    end

    context 'when password is more than one character long' do
      context 'and only digits' do
        it 'should return 10' do
          subject.bruteforce_cardinality('123456789').should eql 10
        end
      end

      context 'and only lowercase characters' do
        it 'should return 26' do
          subject.bruteforce_cardinality('password').should eql 26
        end
      end

      context 'and only uppercase characters' do
        it 'should return 26' do
          subject.bruteforce_cardinality('PASSWORD').should eql 26
        end
      end

      context 'and only symbols' do
        it 'should return 33' do
          subject.bruteforce_cardinality('/ [ ` {').should eql 33
        end
      end

      context 'and a mixed of character types' do
        it 'should add up every character type cardinality' do
          subject.bruteforce_cardinality('p1SsWorD!').should eql 95
        end
      end
    end
  end
end