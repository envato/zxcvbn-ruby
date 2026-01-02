# frozen_string_literal: true

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
      expect(matches.map(&:matched_word)).not_to include 'password'
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

    it 'marks all matches as l33t' do
      expect(matches.map(&:l33t).uniq).to eq([true])
    end

    it 'sets the sub_display field' do
      expect(matches.first.sub_display).to eq('@ -> a')
    end

    context 'with no l33t characters' do
      it 'returns empty array for password without l33t chars' do
        expect(matcher.matches('password')).to be_empty
      end

      it 'returns empty array for simple words' do
        expect(matcher.matches('hello')).to be_empty
      end
    end

    context 'with multiple l33t substitutions' do
      it 'handles multiple substitution types' do
        matches = matcher.matches('p@ssw0rd')
        expect(matches).not_to be_empty
        expect(matches.any? { |m| m.sub.keys.include?('@') }).to be true
        expect(matches.any? { |m| m.sub.keys.include?('0') }).to be true
      end

      it 'creates correct sub_display for multiple substitutions' do
        matches = matcher.matches('h3ll0')
        multi_sub_match = matches.find { |m| m.sub.length > 1 }
        expect(multi_sub_match.sub_display).to include('->')
      end
    end

    context 'with same character representing different letters' do
      it 'handles ambiguous l33t characters' do
        # '1' can represent both 'i' and 'l'
        matches = matcher.matches('test1ng')
        expect(matches).not_to be_empty
      end
    end

    context 'with uppercase l33t speak' do
      it 'finds matches in mixed case passwords' do
        matches = matcher.matches('P@ssW0RD')
        expect(matches).not_to be_empty
      end

      it 'preserves original case in token' do
        matches = matcher.matches('P@SS')
        uppercase_match = matches.find { |m| m.token == 'P@S' }
        expect(uppercase_match).not_to be_nil
        expect(uppercase_match.token).to eq('P@S')
        expect(uppercase_match.matched_word).to eq('pas')
      end
    end

    context 'with edge cases' do
      it 'handles empty password' do
        expect(matcher.matches('')).to be_empty
      end

      it 'handles password with only l33t characters' do
        matches = matcher.matches('@$')
        expect(matches).to be_an(Array)
      end

      it 'handles repeated l33t characters' do
        matches = matcher.matches('@@@@')
        expect(matches).to be_an(Array)
      end
    end
  end

  describe '#translate' do
    it 'substitutes l33t characters with their letter equivalents' do
      substitution = { '@' => 'a', '0' => 'o' }
      expect(matcher.translate('p@ssw0rd', substitution)).to eq('password')
    end

    it 'leaves non-substituted characters unchanged' do
      substitution = { '@' => 'a' }
      expect(matcher.translate('p@ssword', substitution)).to eq('password')
    end

    it 'handles empty password' do
      expect(matcher.translate('', { '@' => 'a' })).to eq('')
    end

    it 'handles empty substitution table' do
      expect(matcher.translate('password', {})).to eq('password')
    end

    it 'handles multiple occurrences of same character' do
      substitution = { '@' => 'a' }
      expect(matcher.translate('@@@@', substitution)).to eq('aaaa')
    end

    it 'only substitutes specified characters' do
      substitution = { '3' => 'e' }
      expect(matcher.translate('l33t', substitution)).to eq('leet')
    end
  end
end
