require 'spec_helper'

describe Zxcvbn::Matching::Dictionary do
  let(:matcher) { described_class.new(dictionary) }
  let(:dictionary) { Zxcvbn::RANKED_DICTIONARIES['english'] }

  it 'finds all the matches' do
    matches = matcher.matches('whatisinit')
    matches.count.should == 14
    expected_matches = ['wha', 'what', 'ha', 'hat', 'a', 'at', 'tis', 'i', 'is',
                       'sin', 'i', 'in', 'i', 'it']
    matches.map(&:matched_word).should == expected_matches
  end

  context 'integration' do
    def dictionary_match(password, dictionary)
      method_invoker.eval_convert_object(%'dictionary_match("#{password}", build_ranked_dict(#{dictionary}))')
    end

    %w[ viking briansmith4mayor ].each do |password|
      it "gives back the same results for #{password}" do
        js_results = dictionary_match(password, 'english')
        ruby_results = matcher.matches(password)
        js_results.count.should eq ruby_results.count
        %w[ matched_word token i j rank pattern ].each do |attribute|
          js_results.each_with_index do |js_result, index|
            js_result[attribute].should eq ruby_results[index].send(attribute)
          end
        end
      end
    end
  end
end