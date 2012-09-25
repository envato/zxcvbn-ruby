require 'spec_helper'

describe Zxcvbn::Matching::Repeat do
  let(:matcher) { subject }
  let(:matches) { matcher.matches('bbbbbtestingaaa') }

  it 'sets the pattern name' do
    matches.all? { |m| m.pattern == 'repeat' }.should be_true
  end

  it 'finds the repeated patterns' do
    matches.count.should eq 2
    matches[0].token.should eq 'bbbbb'
    matches[0].repeated_char.should eq 'b'
    matches[1].token.should eq 'aaa'
    matches[1].repeated_char.should eq 'a'
  end

  context 'integration' do
    def js_repeat_match(password)
      run_js(%'repeat_match("#{password}")')
    end

    TEST_PASSWORDS.each do |password|
      it "gives back the same results for #{password}" do
        js_results = js_repeat_match(password)
        ruby_results = matcher.matches(password)
        ruby_results.should match_js_results js_results
      end
    end
  end
end