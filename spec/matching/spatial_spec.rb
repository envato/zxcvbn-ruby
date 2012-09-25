require 'spec_helper'

describe Zxcvbn::Matching::Spatial do
  let(:matcher) { Zxcvbn::Matching::Spatial.new(graphs) }
  let(:graphs)  { Zxcvbn::ADJACENCY_GRAPHS }

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

  context 'integration' do
    def js_spatial_match(password)
      run_js(%'spatial_match("#{password}")')
    end

    TEST_PASSWORDS.each do |password|
      it "gives back the same results for #{password}" do
        js_results = js_spatial_match(password)
        ruby_results = matcher.matches(password)
        ruby_results.should match_js_results js_results
      end
    end
  end
end