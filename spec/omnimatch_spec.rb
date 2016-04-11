require 'spec_helper'

describe Zxcvbn::Omnimatch do
  before(:all) do
    @omnimatch = described_class.new(Zxcvbn::Data.new)
  end

  def omnimatch(password)
    @omnimatch.matches(password)
  end

  def js_omnimatch(password)
    run_js(%'omnimatch("#{password}")')
  end

  TEST_PASSWORDS.each do |password|
    it "gives back the same results for #{password}" do
      js_results = js_omnimatch(password)
      ruby_results = omnimatch(password)

      expect(ruby_results).to match_js_results js_results
    end
  end
end