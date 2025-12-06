# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Matchers::Dictionary do
  subject(:matcher) { described_class.new('Test dictionary', dictionary) }

  describe '#matches' do
    let(:matches) { matcher.matches(password) }
    let(:matched_words) { matches.map(&:matched_word) }

    context 'Given a dictionary of English words' do
      let(:dictionary) { Zxcvbn::Data.new.ranked_dictionaries['english'] }
      let(:password) { 'whatisinit' }

      it 'finds all the matches' do
        expect(matched_words).to match_array %w[wha what ha hat a at tis i is sin i in i it]
      end
    end

    context 'Given a custom dictionary' do
      let(:dictionary) { Zxcvbn::DictionaryRanker.rank_dictionary(%w[test AB10CD]) }
      let(:password) { 'AB10CD' }

      it 'matches uppercase passwords with normalised dictionary entries' do
        expect(matched_words).to match_array(%w[ab10cd])
      end
    end
  end
end
