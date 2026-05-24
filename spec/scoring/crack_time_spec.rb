# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::CrackTime do
  include Zxcvbn::CrackTime

  describe '#guesses_to_score' do
    it 'returns 0 for fewer than 1000 guesses' do
      expect(guesses_to_score(500)).to eq 0
    end

    it 'returns 1 for 1000–1_000_000 guesses' do
      expect(guesses_to_score(50_000)).to eq 1
    end

    it 'returns 2 for 1_000_000–100_000_000 guesses' do
      expect(guesses_to_score(5_000_000)).to eq 2
    end

    it 'returns 3 for 100_000_000–10_000_000_000 guesses' do
      expect(guesses_to_score(500_000_000)).to eq 3
    end

    it 'returns 4 for 10_000_000_000 or more guesses' do
      expect(guesses_to_score(50_000_000_000)).to eq 4
    end
  end

  describe '#display_time' do
    let(:minute)  { 60 }
    let(:hour)    { minute * 60 }
    let(:day)     { hour * 24 }
    let(:month)   { day * 31 }
    let(:year)    { month * 12 }
    let(:century) { year * 100 }

    it 'returns instant for less than a minute' do
      [0, minute - 1].each { |s| expect(display_time(s)).to eq 'instant' }
    end

    it 'returns minutes for less than an hour' do
      [minute, hour - 1].each { |s| expect(display_time(s)).to match(/\d+ minutes$/) }
    end

    it 'returns hours for less than a day' do
      [hour, day - 1].each { |s| expect(display_time(s)).to match(/\d+ hours$/) }
    end

    it 'returns days for less than a month' do
      [day, month - 1].each { |s| expect(display_time(s)).to match(/\d+ days$/) }
    end

    it 'returns months for less than a year' do
      [month, year - 1].each { |s| expect(display_time(s)).to match(/\d+ months$/) }
    end

    it 'returns years for less than a century' do
      [year, century - 1].each { |s| expect(display_time(s)).to match(/\d+ years$/) }
    end

    it 'returns centuries for a century or more' do
      expect(display_time(century)).to eq 'centuries'
    end
  end
end
