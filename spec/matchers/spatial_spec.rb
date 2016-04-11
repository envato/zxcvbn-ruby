require 'spec_helper'

describe Zxcvbn::Matchers::Spatial do
  let(:matcher) { Zxcvbn::Matchers::Spatial.new(graphs) }
  let(:graphs)  { Zxcvbn::Data.new.adjacency_graphs }

  describe '#matches' do
    let(:matches) { matcher.matches('rtyikm') }

    it 'finds the correct of matches' do
      expect(matches.count).to eq 3
      expect(matches[0].token).to eq 'rty'
      expect(matches[0].graph).to eq 'qwerty'
      expect(matches[1].token).to eq 'ikm'
      expect(matches[1].graph).to eq 'qwerty'
      expect(matches[2].token).to eq 'yik'
      expect(matches[2].graph).to eq 'dvorak'
    end
  end
end