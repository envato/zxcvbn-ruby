require 'spec_helper'

describe Zxcvbn::Scoring do
  include Zxcvbn

  context 'integration' do
    def js_score(password)
      method_invoker.eval_convert_object(%'minimum_entropy_match_sequence("#{password}", omnimatch("#{password}"))')
    end

    def score(password)
      Zxcvbn::Scoring.new(password, omnimatch(password)).minimum_entropy_match_sequence
    end

    TEST_PASSWORDS.each do |password|
      it "gives back the same results for #{password}" do
        js_result = js_score(password)
        ruby_result = score(password)

        ruby_result.password.should eq js_result['password']
        ruby_result.entropy.should eq js_result['entropy']
        ruby_result.crack_time.should eq js_result['crack_time']
        ruby_result.crack_time_display.should eq js_result['crack_time_display']
        ruby_result.score.should eq js_result['score']
        ruby_result.pattern.should eq js_result['pattern']
      end
    end
  end
end