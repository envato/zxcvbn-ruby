require 'spec_helper'

describe Zxcvbn::Matching::Dictionary do
  let(:matcher) { described_class.new('english', dictionary) }
  let(:dictionary) { Zxcvbn::RANKED_DICTIONARIES['english'] }

  it 'finds all the matches' do
    matches = matcher.matches('whatisinit')
    matches.count.should == 14
    expected_matches = ['wha', 'what', 'ha', 'hat', 'a', 'at', 'tis', 'i', 'is',
                       'sin', 'i', 'in', 'i', 'it']
    matches.map(&:matched_word).should == expected_matches
  end

  context 'integration' do
    let(:dictionary_matchers) {
      Zxcvbn::RANKED_DICTIONARIES.map do |name, dictionary|
        Zxcvbn::Matching::Dictionary.new(name, dictionary)
      end
    }

    def dictionary_match(password)
      dictionary_matchers.map do |matcher|
        matcher.matches(password)
      end.flatten
    end

    def js_dictionary_match(password)
      Zxcvbn::RANKED_DICTIONARIES.keys.map do |name|
        method_invoker.eval_convert_object(%'build_dict_matcher("#{name}", build_ranked_dict(#{name}))("#{password}")')
      end.flatten
    end

    TEST_PASSWORDS.each do |password|
      it "gives back the same results for #{password}" do
        js_results = js_dictionary_match(password)
        ruby_results = dictionary_match(password)
        ruby_results.count.should eq js_results.uniq.count
        ruby_results.should match_js_results js_results
      end
    end
  end
end