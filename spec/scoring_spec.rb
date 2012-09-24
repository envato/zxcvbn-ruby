require 'spec_helper'

describe Zxcvbn::Scoring do
  include Zxcvbn

  context 'integration' do
    def js_score(password)
      method_invoker.eval_convert_object(%'minimum_entropy_match_sequence("#{password}", omnimatch("#{password}"))')
    end

    def ruby_score(password)
      Zxcvbn::Scoring.new(password, omnimatch(password)).minimum_entropy_match_sequence
    end

    it 'returns the same result for password' do
      password = 'password'
      js_result = js_score(password)
      ruby_result = ruby_score(password)

      %w|password entropy crack_time crack_time_display score pattern|.each do |property|
        ruby_result.instance_eval(property).should eq js_result[property]
      end
    end
  end

  describe '#bruteforce_cardinality' do
    it 'returns the bruteforce cardinately for password' do
      Score.new('password').bruteforce_cardinality.should eql 26
    end

    context 'when empty password' do
      it 'should return 0 if empty password' do
        Score.new('').bruteforce_cardinality.should eql 0
      end
    end

    context 'when password is one character long' do
      context 'and a digit' do
        it 'should return 10' do
          (0..9).each do |digit|
            Score.new(digit.to_s).bruteforce_cardinality.should eql 10
          end
        end
      end

      context 'and an upper case character' do
        it 'should return 26' do
          ('A'..'Z').each do |character|
            Score.new(character).bruteforce_cardinality.should eql 26
          end
        end
      end

      context 'and a lower case character' do
        it 'should return 26' do
          ('a'..'z').each do |character|
            Score.new(character).bruteforce_cardinality.should eql 26
          end
        end
      end

      context 'and a symbol' do
        it 'should return 33' do
          %w|/ [ ` {|.each do |symbol|
            Score.new(symbol).bruteforce_cardinality.should eql 33
          end
        end
      end
    end
  end
end