# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Scorer do
  subject(:scorer) { described_class.new(nil) }

  describe '#most_guessable_match_sequence' do
    context 'with an empty password' do
      it 'returns guesses of 1 and an empty sequence' do
        result = scorer.most_guessable_match_sequence('', [])
        expect(result.guesses).to eq 1
        expect(result.sequence).to be_empty
      end
    end

    context 'with no matches (bruteforce only)' do
      it 'returns a single bruteforce match spanning the whole password' do
        result = scorer.most_guessable_match_sequence('abc', [])
        expect(result.guesses).to eq 1001
        expect(result.sequence.count).to eq 1
        expect(result.sequence.first.pattern).to eq 'bruteforce'
        expect(result.sequence.first.token).to eq 'abc'
      end
    end

    context 'with a single match spanning the full password' do
      it 'selects the match over a bruteforce fallback' do
        match = Zxcvbn::Match.new(pattern: 'dictionary', i: 0, j: 2, token: 'abc', rank: 1)
        result = scorer.most_guessable_match_sequence('abc', [match])
        expect(result.guesses).to eq 2
        expect(result.sequence).to eq [match]
      end
    end

    context 'with two adjacent matches covering the full password' do
      let(:match1) { Zxcvbn::Match.new(pattern: 'dictionary', i: 0, j: 3, token: 'abcd', rank: 1) }
      let(:match2) { Zxcvbn::Match.new(pattern: 'dictionary', i: 4, j: 7, token: 'efgh', rank: 1) }

      it 'chains the matches and applies the sequence-length penalty' do
        result = scorer.most_guessable_match_sequence('abcdefgh', [match1, match2])
        expect(result.guesses).to eq 15_000
        expect(result.sequence).to eq [match1, match2]
      end

      it 'omits the sequence-length penalty when exclude_additive is true' do
        result = scorer.most_guessable_match_sequence('abcdefgh', [match1, match2], exclude_additive: true)
        expect(result.guesses).to eq 5_000
        expect(result.sequence).to eq [match1, match2]
      end
    end

    context 'with three non-overlapping matches covering the full password' do
      # 4-char subtokens on a 12-char password: bruteforce of any 8-char prefix (10^8)
      # is far more expensive than the 3-match path, so the DP picks the 3 matches.
      let(:match_a) { Zxcvbn::Match.new(pattern: 'dictionary', i: 0, j: 3, token: 'abcd', rank: 1) }
      let(:match_b) { Zxcvbn::Match.new(pattern: 'dictionary', i: 4, j: 7, token: 'efgh', rank: 1) }
      let(:match_c) { Zxcvbn::Match.new(pattern: 'dictionary', i: 8, j: 11, token: 'ijkl', rank: 1) }

      it 'chains all three and applies the sequence-length penalty' do
        # Each subtoken min_guesses=50; l=3: 3! × 50³ + 10000² = 750_000 + 100_000_000
        result = scorer.most_guessable_match_sequence('abcdefghijkl', [match_a, match_b, match_c])
        expect(result.sequence).to eq [match_a, match_b, match_c]
        expect(result.guesses).to eq 100_750_000
      end
    end

    context 'bruteforce chain prevention' do
      it 'does not build a multi-match sequence from bruteforce segments only' do
        result = scorer.most_guessable_match_sequence('ab', [])
        expect(result.sequence.count).to eq 1
        expect(result.sequence.first.token).to eq 'ab'
      end
    end
  end
end
