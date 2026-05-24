# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Omnimatch do
  let(:data) { Zxcvbn::Data.new }
  let(:omnimatch) { described_class.new(data) }

  # reverse_dictionary_matches is private; tested through the public matches interface.
  describe 'reverse dictionary matching' do
    def reversed_matches(password, user_inputs = [])
      omnimatch.matches(password, user_inputs).select(&:reversed)
    end

    it 'finds a built-in dictionary word spelled backwards' do
      matches = reversed_matches('drowssap')
      expect(matches.any? { |m| m.matched_word == 'password' }).to be true
    end

    it 'restores the token to the original (un-reversed) form' do
      match = reversed_matches('drowssap').find { |m| m.matched_word == 'password' }
      expect(match.token).to eq 'drowssap'
    end

    it 'sets the reversed flag' do
      match = reversed_matches('drowssap').find { |m| m.matched_word == 'password' }
      expect(match.reversed).to be true
    end

    it 'flips i/j coordinates back to the original password space' do
      # password = "xxecila" (n=7), user_inputs = ["alice"]
      # reversed  = "alicexx"; "alice" found at i=0, j=4
      # flip: i' = 7-1-4 = 2, j' = 7-1-0 = 6
      # "xxecila"[2..6] == "ecila" ✓
      match = reversed_matches('xxecila', ['alice']).find do |m|
        m.dictionary_name == 'user_inputs'
      end
      expect(match.i).to eq 2
      expect(match.j).to eq 6
    end

    it 'includes user-input words in the reverse pass' do
      matches = reversed_matches('ecila', ['alice'])
      user_match = matches.find { |m| m.dictionary_name == 'user_inputs' }
      expect(user_match).not_to be_nil
      expect(user_match.token).to eq 'ecila'
      expect(user_match.i).to eq 0
      expect(user_match.j).to eq 4
    end
  end
end
