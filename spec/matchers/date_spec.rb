require 'spec_helper'

describe Zxcvbn::Matchers::Date do
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
        expect(matches[0].token).to eq %w[ 02 12 1997 ].join(separator)
        expect(matches[0].separator).to eq separator
        expect(matches[0].day).to eq 2
        expect(matches[0].month).to eq 12
        expect(matches[0].year).to eq 1997
      end
    end
  end

  # context 'without separator' do
  #   context '5 digit date' do
  #     let(:matches) { matcher.matches('13192boo') }

  #     it 'finds matches' do
  #       matches.should_not be_empty
  #     end

  #     it 'finds the correct matches' do
  #       matches.count.should eq 2
  #       matches[0].token.should eq '13192'
  #       matches[0].separator.should eq ''
  #       matches[0].day.should eq 13
  #       matches[0].month.should eq 1
  #       matches[0].year.should eq 1992

  #       matches[1].token.should eq '13192'
  #       matches[1].separator.should eq ''
  #       matches[1].day.should eq 31
  #       matches[1].month.should eq 1
  #       matches[1].year.should eq 1992
  #     end
  #   end
  # end

  # describe '#extract_dates' do
  #   {
  #     '1234' => [
  #       {:year => 2012, :month => 3, :day => 4},
  #       {:year => 1934, :month => 2, :day => 1},
  #       {:year => 1934, :month => 1, :day => 2}
  #     ],
  #     '12345' => [
  #       {:year => 1945, :month => 3, :day => 12},
  #       {:year => 1945, :month => 12, :day => 3},
  #       {:year => 1945, :month => 1, :day => 23}
  #     ],
  #     '54321' => [
  #       {:year => 1954, :month => 3, :day => 21}
  #     ],
  #     '151290' => [
  #       {:year => 1990, :month => 12, :day => 15}
  #     ],
  #     '901215' => [
  #       {:year => 1990, :month => 12, :day => 15}
  #     ],
  #     '1511990' => [
  #       {:year => 1990, :month => 1, :day => 15}
  #     ]
  #   }.each do |token, expected_candidates|
  #     it "finds the correct candidates for #{token}" do
  #       matcher.extract_dates(token).should match_array expected_candidates
  #     end
  #   end
  # end

  # describe '#expand_year' do
  #   {
  #     12 => 2012,
  #     01 => 2001,
  #     15 => 2015,
  #     19 => 2019,
  #     20 => 1920
  #   }.each do |small, expanded|
  #     it "expands #{small} to #{expanded}" do
  #       matcher.expand_year(small).should eq expanded
  #     end
  #   end
  # end

  context 'invalid date' do
    let(:matches) { matcher.matches('testing0.x.1997') }

    it 'doesnt match' do
      expect(matches).to be_empty
    end
  end
end