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

end