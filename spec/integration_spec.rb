require 'spec_helper'

describe 'zxcvbn over a set of example passwords' do
  include Zxcvbn

  it 'gives back the same score' do
    pending do
      TEST_PASSWORDS.each do |password|
        zxcvbn(password).should eq js_zxcvbn(password)
      end
    end
  end

  def js_omnimatch(password)
    method_invoker.eval_convert_object(%'omnimatch("#{password}")')
  end

  TEST_PASSWORDS.each do |password|
    it "gives back the same results for #{password}" do
      js_results = js_omnimatch(password)
      ruby_results = omnimatch(password)

      ruby_results.should match_js_results js_results
    end
  end

end