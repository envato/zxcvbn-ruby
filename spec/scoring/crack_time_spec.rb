require 'spec_helper'

describe Zxcvbn::Scoring::CrackTime do
  include Zxcvbn::Scoring::CrackTime

  describe '#entropy_to_crack_time' do
    specify do
      entropy_to_crack_time(15.433976574415976).should eq 2.2134000000000014
    end
  end

  describe '#crack_time_to_score' do
    context 'crack time less than 10 to the power 2' do
      it 'returns 0' do
        crack_time_to_score(90).should eq 0
      end
    end

    context 'crack time in between 10**2 and 10**4' do
      it 'returns 1' do
        crack_time_to_score(5000).should eq 1
      end
    end

    context 'crack time in between 10**4 and 10**6' do
      it 'returns 2' do
        crack_time_to_score(500_000).should eq 2
      end
    end

    context 'crack time in between 10**6 and 10**8' do
      it 'returns 3' do
        crack_time_to_score(50_000_000).should eq 3
      end
    end

    context 'crack time above 10**8' do
      it 'returns 4' do
        crack_time_to_score(110_000_000).should eq 4
      end
    end
  end
end