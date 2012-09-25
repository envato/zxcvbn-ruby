require 'spec_helper'

describe Zxcvbn::Scoring::Entropy do
  let(:entropy) {
    Class.new do
      include Zxcvbn::Scoring::Entropy
    end.new
  }

  describe '#digits_entropy' do
    it 'behaves the same as the js version' do
      match = Zxcvbn::Match.new(:token => '12345678')
      js_digits_entropy = method_invoker.eval(%'digits_entropy({token: "#{match.token}"})')
      ruby_digits_entropy = entropy.digits_entropy(match)
      ruby_digits_entropy.should eq js_digits_entropy
    end
  end

  
end