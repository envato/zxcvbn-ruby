require 'spec_helper'

describe Zxcvbn::Matching::Year do
  let(:matcher) { subject }
  let(:matches) { matcher.matches('testing1998') }

  it 'sets the pattern name' do
    matches.all? { |m| m.pattern == 'year' }.should be_true
  end

  it 'finds the correct matches' do
    matches.count.should == 1
    matches[0].token.should eq '1998'
  end

  context 'integration' do
    def js_year_match(password)
      run_js(%'year_match("#{password}")')
    end

    TEST_PASSWORDS.each do |password|
      it "gives back the same results for #{password}" do
        js_results = js_year_match(password)
        ruby_results = matcher.matches(password)
        ruby_results.should match_js_results js_results
      end
    end
  end
end