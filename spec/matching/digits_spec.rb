require 'spec_helper'

describe Zxcvbn::Matching::Digits do
  let(:matcher) { subject }
  let(:matches) { matcher.matches('testing1239xx9712') }

  it 'sets the pattern name' do
    matches.all? { |m| m.pattern == 'digits' }.should be_true
  end

  it 'finds the correct matches' do
    matches.count.should == 2
    matches[0].token.should eq '1239'
  end

  context 'integration' do
    def js_digits_match(password)
      method_invoker.eval_convert_object(%'digits_match("#{password}")')
    end

    TEST_PASSWORDS.each do |password|
      it "gives back the same results for #{password}" do
        js_results = js_digits_match(password)
        ruby_results = matcher.matches(password)
        ruby_results.should match_js_results js_results
      end
    end
  end
end