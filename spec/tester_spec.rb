require 'spec_helper'

describe Zxcvbn::Tester do
  let(:tester) { Zxcvbn::Tester.new }

  TEST_PASSWORDS.each do |password|
    it "gives back the same score for #{password}" do
      ruby_result = tester.test(password)
      js_result = js_zxcvbn(password)

      ruby_result.score.should eq js_result["score"]
      #ruby_result.to_json.should eq js_result
    end
  end
end
