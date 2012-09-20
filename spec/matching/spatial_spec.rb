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
    def spatial_match(password)
      method_invoker.eval_convert_object(%'spatial_match("#{password}")')
    end

    def match_to_hash_with_string_keys(matches)
      matches.map do |match|
        hash = match.instance_variable_get('@table')
        hash.keys.each do |key|
          hash[key.to_s] = hash.delete(key)
        end
        hash
      end
    end

    %w[ rtyikm ].each do |password|
      it "gives back the same result for #{password}" do
        results_as_hash = match_to_hash_with_string_keys(matcher.matches(password))
        results_as_hash.should eq(spatial_match(password, ))
      end
    end
  end
end