require 'spec_helper'

describe Zxcvbn::CrackTime do
  include Zxcvbn::CrackTime

  describe '#entropy_to_crack_time' do
    specify do
      expect(entropy_to_crack_time(15.433976574415976)).to eq 2.2134000000000014
    end
  end

  describe '#crack_time_to_score' do
    context 'crack time less than 10 to the power 2' do
      it 'returns 0' do
        expect(crack_time_to_score(90)).to eq 0
      end
    end

    context 'crack time in between 10**2 and 10**4' do
      it 'returns 1' do
        expect(crack_time_to_score(5000)).to eq 1
      end
    end

    context 'crack time in between 10**4 and 10**6' do
      it 'returns 2' do
        expect(crack_time_to_score(500_000)).to eq 2
      end
    end

    context 'crack time in between 10**6 and 10**8' do
      it 'returns 3' do
        expect(crack_time_to_score(50_000_000)).to eq 3
      end
    end

    context 'crack time above 10**8' do
      it 'returns 4' do
        expect(crack_time_to_score(110_000_000)).to eq 4
      end
    end
  end

  describe '#display_time' do
    let(:minute_to_seconds)  { 60 }
    let(:hour_to_seconds)    { minute_to_seconds * 60 }
    let(:day_to_seconds)     { hour_to_seconds * 24 }
    let(:month_to_seconds)   { day_to_seconds * 31 }
    let(:year_to_seconds)    { month_to_seconds * 12 }
    let(:century_to_seconds) { year_to_seconds * 100 }

    context 'when less than a minute' do
      it 'should return instant' do
        [0, minute_to_seconds - 1].each do |seconds|
          expect(display_time(seconds)).to eql 'instant'
        end
      end
    end

    context 'when less than an hour' do
      it 'should return a readable time in minutes' do
        [60, (hour_to_seconds - 1)].each do |seconds|
          expect(display_time(seconds)).to match(/[0-9]+ minutes$/)
        end
      end
    end

    context 'when less than a day' do
      it 'should return a readable time in hours' do
        [hour_to_seconds, (day_to_seconds - 1)].each do |seconds|
          expect(display_time(seconds)).to match(/[0-9]+ hours$/)
        end
      end
    end

    context 'when less than 31 days' do
      it 'should return a readable time in days' do
        [day_to_seconds, month_to_seconds - 1].each do |seconds|
          expect(display_time(seconds)).to match(/[0-9]+ days$/)
        end
      end
    end

    context 'when less than 1 year' do
      it 'should return a readable time in days' do
        [month_to_seconds, (year_to_seconds - 1)].each do |seconds|
          expect(display_time(seconds)).to match(/[0-9]+ months$/)
        end
      end
    end

    context 'when less than a century' do
      it 'should return a readable time in days' do
        [year_to_seconds, (century_to_seconds - 1)].each do |seconds|
          expect(display_time(seconds)).to match(/[0-9]+ years$/)
        end
      end
    end

    context 'when a century or more' do
      it 'should return centuries' do
        expect(display_time(century_to_seconds)).to eql 'centuries'
      end
    end
  end
end