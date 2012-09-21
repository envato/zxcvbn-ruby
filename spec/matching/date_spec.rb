require 'spec_helper'

describe Zxcvbn::Matching::Date do
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
        matches.should_not be_empty
      end

      it 'finds the correct matches' do
        matches.count.should eq 1
        matches[0].token.should eq %w[ 02 12 1997 ].join(separator)
        matches[0].separator.should eq separator
        matches[0].day.should eq 2
        matches[0].month.should eq 12
        matches[0].year.should eq 1997
        matches[0].i.should eq 7
        matches[0].j.should eq 17
      end
    end
  end

  context 'without separator and 4 digit date' do
    let(:matches) { matcher.matches('13192boo') }

    it 'finds matches' do
      matches.should_not be_empty
    end

    it 'finds the correct matches' do
      matches.count.should eq 2
      debugger
      matches[0].token.should eq '13192'
      matches[0].separator.should eq ''
      matches[0].day.should eq 19
      matches[0].month.should eq 2
      matches[0].year.should eq 13
      matches[0].i.should eq 0
      matches[0].j.should eq 5
    end
  end

  context 'invalid date' do
    let(:matches) { matcher.matches('testing0.x.1997') }

    it 'doesnt match' do
      matches.should be_empty
    end
  end
end