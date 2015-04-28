require 'spec_helper'

describe Zxcvbn::Matchers::Spatial do
  let(:matcher) { Zxcvbn::Matchers::Spatial.new(graphs) }
  let(:graphs)  { Zxcvbn::Data.new.adjacency_graphs }

  describe '#matches' do
    let(:matches) { matcher.matches('rtyikm') }

    it 'finds the correct of matches' do
      matches.count.should eq 3
      matches[0].token.should eq 'rty'
      matches[0].graph.should eq 'qwerty'
      matches[1].token.should eq 'ikm'
      matches[1].graph.should eq 'qwerty'
      matches[2].token.should eq 'yik'
      matches[2].graph.should eq 'dvorak'
    end
  end
end