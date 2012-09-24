require 'spec_helper'

describe 'zxcvbn over a set of example passwords' do
  include Zxcvbn

  # 35
  

  it 'gives back the same score' do
    pending do
      TEST_PASSWORDS.each do |password|
        zxcvbn(password).should eq js_zxcvbn(password)
      end
    end
  end

  TEST_PASSWORDS.each do |password|
    it "gives back the same number of matches for #{password}" do
      results = match_to_hash_with_string_keys(omnimatch(password))
      js_results = method_invoker.eval_convert_object(%'omnimatch("#{password}")')
      # debugg
      # ap results
      # debugger
      # ap js_results
      results.should match_array js_results
      results.count.should eq js_results.count
    end
  end
end