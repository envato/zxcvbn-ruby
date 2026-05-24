# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Scorer do
  subject(:scorer) { described_class.new(nil) }

  describe '#most_guessable_match_sequence' do
    context 'with an empty password' do
      it 'returns guesses of 1 and an empty sequence' do
        result = scorer.most_guessable_match_sequence('', [])
        expect(result.guesses).to eq 1
        expect(result.match_sequence).to be_empty
      end
    end

    context 'with no matches (bruteforce only)' do
      it 'returns a single bruteforce match spanning the whole password' do
        result = scorer.most_guessable_match_sequence('abc', [])
        expect(result.guesses).to eq 1001
        expect(result.match_sequence.count).to eq 1
        expect(result.match_sequence.first.pattern).to eq 'bruteforce'
        expect(result.match_sequence.first.token).to eq 'abc'
      end
    end

    context 'with a single match spanning the full password' do
      it 'selects the match over a bruteforce fallback' do
        match = Zxcvbn::Match.new(pattern: 'dictionary', i: 0, j: 2, token: 'abc', rank: 1)
        result = scorer.most_guessable_match_sequence('abc', [match])
        expect(result.guesses).to eq 2
        expect(result.match_sequence).to eq [match]
      end
    end

    context 'with two adjacent matches covering the full password' do
      let(:match1) { Zxcvbn::Match.new(pattern: 'dictionary', i: 0, j: 3, token: 'abcd', rank: 1) }
      let(:match2) { Zxcvbn::Match.new(pattern: 'dictionary', i: 4, j: 7, token: 'efgh', rank: 1) }

      it 'chains the matches and applies the sequence-length penalty' do
        result = scorer.most_guessable_match_sequence('abcdefgh', [match1, match2])
        expect(result.guesses).to eq 15_000
        expect(result.match_sequence).to eq [match1, match2]
      end

      it 'omits the sequence-length penalty when exclude_additive is true' do
        result = scorer.most_guessable_match_sequence('abcdefgh', [match1, match2], exclude_additive: true)
        expect(result.guesses).to eq 5_000
        expect(result.match_sequence).to eq [match1, match2]
      end
    end

    context 'bruteforce chain prevention' do
      it 'does not build a multi-match sequence from bruteforce segments only' do
        result = scorer.most_guessable_match_sequence('ab', [])
        expect(result.match_sequence.count).to eq 1
        expect(result.match_sequence.first.token).to eq 'ab'
      end
    end
  end
end
