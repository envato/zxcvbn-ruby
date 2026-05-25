# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Matchers::Repeat do
  let(:matcher) { subject }

  context 'with single-character repeats' do
    let(:matches) { matcher.matches('bbbbbtestingaaa') }

    it 'sets the pattern name' do
      expect(matches.all? { |m| m.pattern == 'repeat' }).to be true
    end

    it 'finds both repeated runs' do
      expect(matches.count).to eq 2
      expect(matches[0].token).to eq 'bbbbb'
      expect(matches[0].base_token).to eq 'b'
      expect(matches[0].repeat_count).to eq 5
      expect(matches[1].token).to eq 'aaa'
      expect(matches[1].base_token).to eq 'a'
      expect(matches[1].repeat_count).to eq 3
    end
  end

  context 'with a multi-character base token (lazy branch)' do
    # GREEDY and LAZY both match the full "abcabcabc" (length 9 each),
    # so the lazy branch is taken and base_token comes from lazy_match[1].
    let(:matches) { matcher.matches('abcabcabc') }

    it 'finds one match' do
      expect(matches.count).to eq 1
    end

    it 'extracts the correct base_token and repeat_count' do
      expect(matches[0].base_token).to eq 'abc'
      expect(matches[0].repeat_count).to eq 3
    end

    it 'records the full token and position' do
      expect(matches[0].token).to eq 'abcabcabc'
      expect(matches[0].i).to eq 0
      expect(matches[0].j).to eq 8
    end
  end

  context 'with a multi-character base token (greedy branch)' do
    # For "aabaab": LAZY matches "aa" (length 2), GREEDY matches "aabaab"
    # (length 6). Since greedy > lazy, LAZY_ANCHORED extracts the true
    # minimal unit "aab" from the greedy match.
    let(:matches) { matcher.matches('aabaab') }

    it 'finds one match' do
      expect(matches.count).to eq 1
    end

    it 'extracts the minimal repeating unit via LAZY_ANCHORED' do
      expect(matches[0].base_token).to eq 'aab'
      expect(matches[0].repeat_count).to eq 2
    end

    it 'records the full token and position' do
      expect(matches[0].token).to eq 'aabaab'
      expect(matches[0].i).to eq 0
      expect(matches[0].j).to eq 5
    end
  end
end
