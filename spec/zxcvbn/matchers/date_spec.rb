# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Matchers::Date do
  let(:matcher) { subject }

  {
    ' ' => 'testing02 12 1997',
    '-' => 'testing02-12-1997',
    '/' => 'testing02/12/1997',
    '\\' => 'testing02\12\1997',
    '_' => 'testing02_12_1997',
    '.' => 'testing02.12.1997'
  }.each do |separator, password|
    context "with #{separator} seperator" do
      let(:matches) { matcher.matches(password) }

      it 'finds matches' do
        expect(matches).not_to be_empty
      end

      it 'finds the correct matches' do
        expect(matches.count).to eq 1
        expect(matches[0].token).to eq %w[02 12 1997].join(separator)
        expect(matches[0].separator).to eq separator
        expect(matches[0].day).to eq 2
        expect(matches[0].month).to eq 12
        expect(matches[0].year).to eq 1997
      end
    end
  end

  {
    ' ' => 'testing1997 12 02',
    '-' => 'testing1997-12-02',
    '/' => 'testing1997/12/02',
    '\\' => 'testing1997\12\02',
    '_' => 'testing1997_12_02',
    '.' => 'testing1997.12.02'
  }.each do |separator, password|
    context "with year-first format and #{separator} separator" do
      let(:matches) { matcher.matches(password) }

      it 'finds the correct match' do
        expect(matches.count).to eq 1
        expect(matches[0].token).to eq %w[1997 12 02].join(separator)
        expect(matches[0].separator).to eq separator
        expect(matches[0].day).to eq 12
        expect(matches[0].month).to eq 2
        expect(matches[0].year).to eq 1997
      end
    end
  end

  {
    ' ' => 'testing97 12 02',
    '-' => 'testing97-12-02',
    '/' => 'testing97/12/02',
    '\\' => 'testing97\12\02',
    '_' => 'testing97_12_02',
    '.' => 'testing97.12.02'
  }.each do |separator, password|
    context "with 2-digit year prefix and #{separator} separator" do
      let(:matches) { matcher.matches(password) }

      it 'finds the correct match' do
        expect(matches.count).to eq 1
        expect(matches[0].token).to eq %w[97 12 02].join(separator)
        expect(matches[0].separator).to eq separator
        expect(matches[0].day).to eq 12
        expect(matches[0].month).to eq 2
        expect(matches[0].year).to eq 1997
      end
    end
  end

  context 'with 2-digit year suffix' do
    let(:matches) { matcher.matches('testing02-12-97') }

    it 'finds and expands the year' do
      expect(matches.count).to eq 1
      expect(matches[0].token).to eq '02-12-97'
      expect(matches[0].separator).to eq '-'
      expect(matches[0].day).to eq 2
      expect(matches[0].month).to eq 12
      expect(matches[0].year).to eq 1997
    end
  end

  describe '#expand_year' do
    {
      12 => 2012,
      1 => 2001,
      15 => 2015,
      50 => 2050,
      51 => 1951,
      99 => 1999,
      100 => 100,
      1997 => 1997
    }.each do |small, expanded|
      it "expands #{small} to #{expanded}" do
        expect(matcher.expand_year(small)).to eq expanded
      end
    end
  end

  describe '#map_ints_to_dmy' do
    it 'identifies year in last position' do
      expect(matcher.map_ints_to_dmy(2, 12, 1997)).to eq({ year: 1997, day: 2, month: 12 })
    end

    it 'identifies year in first position' do
      expect(matcher.map_ints_to_dmy(1997, 12, 2)).to eq({ year: 1997, day: 12, month: 2 })
    end

    it 'expands 2-digit year in last position' do
      expect(matcher.map_ints_to_dmy(2, 12, 97)).to eq({ year: 1997, day: 2, month: 12 })
    end

    it 'expands 2-digit year in first position' do
      expect(matcher.map_ints_to_dmy(97, 12, 2)).to eq({ year: 1997, day: 12, month: 2 })
    end

    it 'returns nil when middle value is zero' do
      expect(matcher.map_ints_to_dmy(2, 0, 1997)).to be_nil
    end

    it 'returns nil when two values exceed 31' do
      expect(matcher.map_ints_to_dmy(1997, 12, 2000)).to be_nil
    end

    it 'returns nil when value is between 99 and DATE_MIN_YEAR' do
      expect(matcher.map_ints_to_dmy(2, 12, 200)).to be_nil
    end
  end

  describe '#match_without_separator' do
    it 'returns exactly one match per numeric token' do
      expect(matcher.match_without_separator('1234').count).to eq 1
    end

    it 'all returned matches are distinct objects' do
      all = matcher.match_without_separator('02121997')
      expect(all.map(&:object_id).uniq.count).to eq all.count
    end

    it 'selects the candidate whose year is closest to the current year' do
      date_matches = matcher.match_without_separator('02121997')
      full = date_matches.find { |m| m.token == '02121997' }
      expect(full).not_to be_nil
      expect(full.year).to eq 1997
    end

    it 'uses the supplied reference_year, not Time.now, to pick the closest candidate' do
      # "1285" splits into candidates: year=1985 (2-digit "85"→1985) and year=2005 (2-digit "05"→2005).
      # reference_year near 1990 picks 1985; reference_year near 2020 picks 2005.
      matches_past = matcher.match_without_separator('1285', reference_year: 1990)
      matches_recent = matcher.match_without_separator('1285', reference_year: 2020)
      full_past = matches_past.find { |m| m.token == '1285' }
      full_recent = matches_recent.find { |m| m.token == '1285' }
      expect(full_past.year).to be < 2000
      expect(full_recent.year).to be >= 2000
    end
  end

  describe '#matches reference_year threading' do
    it 'uses the supplied reference_year rather than Time.now.year' do
      allow(Time).to receive(:now).and_return(double(year: 9999))
      # "1285" has candidates 1985 and 2005. With reference_year=1990, year 1985 wins.
      # If Time.now leaked through it would return 9999 and year 2005 would win instead.
      results = matcher.matches('1285', reference_year: 1990)
      full = results.find { |m| m.token == '1285' }
      expect(full).not_to be_nil
      expect(full.year).to be < 2000
    end
  end

  context 'invalid date' do
    let(:matches) { matcher.matches('testing0.x.1997') }

    it 'doesnt match' do
      expect(matches).to be_empty
    end
  end
end
