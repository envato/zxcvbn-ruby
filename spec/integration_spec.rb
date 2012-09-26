require 'spec_helper'

describe 'zxcvbn over a set of example passwords' do
  include Zxcvbn

  TEST_PASSWORDS.each do |password|
    it "gives back the same score for #{password}" do
      ruby_result = zxcvbn(password)
      js_result = js_zxcvbn(password)

      ruby_result.calc_time.should_not be_nil
      ruby_result.password.should eq js_result['password']
      ruby_result.entropy.should eq js_result['entropy']
      ruby_result.crack_time.should eq js_result['crack_time']
      ruby_result.crack_time_display.should eq js_result['crack_time_display']
      ruby_result.score.should eq js_result['score']
      ruby_result.pattern.should eq js_result['pattern']
      ruby_result.match_sequence.count.should eq js_result['match_sequence'].count
    end
  end

end