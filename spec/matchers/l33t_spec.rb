require 'spec_helper'

describe Zxcvbn::Matchers::L33t do
  let(:matcher) { described_class.new([dictionary_matcher]) }
  let(:dictionary) { Zxcvbn::Data.new.ranked_dictionaries['english'] }
  let(:dictionary_matcher) { Zxcvbn::Matchers::Dictionary.new('english', dictionary) }

  describe '#relevant_l33t_substitutions' do
    it 'returns relevant l33t substitutions' do
      matcher.relevent_l33t_subtable('p@ssw1rd24').should eq(
        {'a' => ['4', '@'], 'i' => ['1'], 'l' => ['1'], 'z' => ['2']}
      )
    end
  end

  describe 'possible l33t substitutions' do
    context 'with 2 possible substitutions' do
      it 'returns the correct possible substitutions' do
        substitutions = {'a' => ['@'], 'i' => ['1']}
        matcher.l33t_subs(substitutions).should match_array([
          {'@' => 'a', '1' => 'i'}
        ])
      end

      it 'returns the correct possible substitutions with multiple options' do
        substitutions = {'a' => ['@', '4'], 'i' => ['1']}
        matcher.l33t_subs(substitutions).should match_array([
          {'@' => 'a', '1' => 'i'},
          {'4' => 'a', '1' => 'i'}
        ])
      end
    end

    context 'with 3 possible substitutions' do
      it 'returns the correct possible substitutions' do
        substitutions = {'a' => ['@'], 'i' => ['1'], 'z' => ['3']}
        matcher.l33t_subs(substitutions).should match_array([
          {'@' => 'a', '1' => 'i', '3' => 'z'}
        ])
      end
    end

    context 'with 4 possible substitutions' do
      it 'returns the correct possible substitutions' do
        substitutions = {'a' => ['@'], 'i' => ['1'], 'z' => ['3'], 'b' => ['8']}
        matcher.l33t_subs(substitutions).should match_array([
          {'@' => 'a', '1' => 'i', '3' => 'z', '8' => 'b'}
        ])
      end
    end
  end

  describe '#matches' do
    let(:matches) { matcher.matches('p@ssword') }
    # it doesn't match on 'password' because that's not in the english
    # dictionary/frequency list

    it 'finds the correct matches' do
      matches.map(&:matched_word).should eq([
        'pas',
        'a',
        'as',
        'ass'
      ])
    end

    it 'sets the token correctly on those matches' do
      matches.map(&:token).should eq([
        'p@s',
        '@',
        '@s',
        '@ss'
      ])
    end

    it 'sets the substituions used' do
      matches.map(&:sub).should eq([
        {'@' => 'a'},
        {'@' => 'a'},
        {'@' => 'a'},
        {'@' => 'a'}
      ])
    end
  end
end