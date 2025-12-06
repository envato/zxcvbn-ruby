require 'spec_helper'

RSpec.describe Zxcvbn::Matchers::L33t do
  let(:matcher) { described_class.new([dictionary_matcher]) }
  let(:dictionary) { Zxcvbn::Data.new.ranked_dictionaries['english'] }
  let(:dictionary_matcher) { Zxcvbn::Matchers::Dictionary.new('english', dictionary) }

  describe '#relevant_l33t_substitutions' do
    it 'returns relevant l33t substitutions' do
      expect(matcher.relevent_l33t_subtable('p@ssw1rd24')).to eq(
        { 'a' => ['4', '@'], 'i' => ['1'], 'l' => ['1'], 'z' => ['2'] }
      )
    end
  end

  describe 'possible l33t substitutions' do
    context 'with 2 possible substitutions' do
      it 'returns the correct possible substitutions' do
        substitutions = { 'a' => ['@'], 'i' => ['1'] }
        expect(matcher.l33t_subs(substitutions)).to match_array([{ '@' => 'a', '1' => 'i' }])
      end

      it 'returns the correct possible substitutions with multiple options' do
        substitutions = { 'a' => ['@', '4'], 'i' => ['1'] }
        expect(matcher.l33t_subs(substitutions)).to match_array(
          [
            { '@' => 'a', '1' => 'i' },
            { '4' => 'a', '1' => 'i' }
          ]
        )
      end
    end

    context 'with 3 possible substitutions' do
      it 'returns the correct possible substitutions' do
        substitutions = { 'a' => ['@'], 'i' => ['1'], 'z' => ['3'] }
        expect(matcher.l33t_subs(substitutions)).to match_array([{ '@' => 'a', '1' => 'i', '3' => 'z' }])
      end
    end

    context 'with 4 possible substitutions' do
      it 'returns the correct possible substitutions' do
        substitutions = { 'a' => ['@'], 'i' => ['1'], 'z' => ['3'], 'b' => ['8'] }
        expect(matcher.l33t_subs(substitutions)).to match_array([{ '@' => 'a', '1' => 'i', '3' => 'z', '8' => 'b' }])
      end
    end
  end

  describe '#matches' do
    subject(:matches) { matcher.matches('p@ssword') }

    it "doesn't find 'password' because it's not in english.txt" do
      expect(matches.map(&:matched_word)).not_to include "password"
    end

    it 'finds the correct matches' do
      expect(matches.map(&:matched_word)).to match_array(%w[pas a as ass])
    end

    it 'sets the token correctly on those matches' do
      expect(matches.map(&:token)).to match_array(%w[p@s @ @s @ss])
    end

    it 'sets the substituions used' do
      expect(matches.map(&:sub)).to match_array(
        [
          { '@' => 'a' },
          { '@' => 'a' },
          { '@' => 'a' },
          { '@' => 'a' }
        ]
      )
    end
  end
end
