require 'spec_helper'

describe Zxcvbn::Matching::Sequences do
  let(:matcher) { subject }
  let(:matches) { matcher.matches('abcde87654') }

  it 'sets the pattern name' do
    matches.all? { |m| m.pattern == 'sequence' }.should be_true
  end

  it 'finds the correct matches' do
    matches.count.should == 2
    matches[0].token.should eq 'abcde'
    matches[1].token.should eq '87654'
  end

  def js_sequence_match(password)
    method_invoker.eval_convert_object(%'sequence_match("#{password}")')
  end

  TEST_PASSWORDS.each do |password|
    it "gives back the same results for #{password}" do
      js_results = js_sequence_match(password)
      ruby_results = matcher.matches(password)
      ruby_results.should match_js_results js_results
    end
  end
end