require 'spec_helper'

describe Zxcvbn::Scoring do
  include Zxcvbn

  context 'integration' do
    def js_score(password)
      method_invoker.eval_convert_object(%'minimum_entropy_match_sequence("#{password}", omnimatch("#{password}"))')
    end

    def ruby_score(password)
      Zxcvbn::Scoring.new(password, omnimatch(password)).minimum_entropy_match_sequence
    end

    it 'returns the same result for password' do
      js_result = js_score('password')
      ruby_result = ruby_score('password')
      ruby_result.entropy.should eq js_result['entropy']
      ruby_result.crack_time.should eq js_result['crack_time']
    end
  end
end