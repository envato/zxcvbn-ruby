require 'spec_helper'

describe 'zxcvbn over a set of example passwords' do
  TEST_PASSWORDS.each do |password|
    it "gives back the same score for #{password}" do
      ruby_result = Zxcvbn.test(password)
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

  context 'with a custom user dictionary' do
    it 'scores them against the user dictionary' do
      result = Zxcvbn.test('themeforest', ['themeforest'])
      result.entropy.should eq 0
      result.score.should eq 0
    end

    it 'matches l33t substitutions on this dictionary' do
      result = Zxcvbn.test('th3m3for3st', ['themeforest'])
      result.entropy.should eq 1
      result.score.should eq 0
    end
  end

  context 'with a custom global dictionary' do
    before { Zxcvbn.add_word_list('envato', ['envato']) }

    it 'scores them against the dictionary' do
      result = Zxcvbn.test('envato')
      result.entropy.should eq 0
      result.score.should eq 0
    end
  end

  context 'nil password' do
    specify do
      expect { Zxcvbn.test(nil) }.to_not raise_error
    end
  end
end