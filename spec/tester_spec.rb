require 'spec_helper'

describe Zxcvbn::Tester do
  let(:tester) { Zxcvbn::Tester.new }

  TEST_PASSWORDS.each do |password|
    it "gives back the same score for #{password}" do
      ruby_result = tester.test(password)
      js_result = js_zxcvbn(password)

      expect(ruby_result.calc_time).not_to be_nil
      expect(ruby_result.password).to eq js_result['password']
      expect(ruby_result.entropy).to eq js_result['entropy']
      expect(ruby_result.crack_time).to eq js_result['crack_time']
      expect(ruby_result.crack_time_display).to eq js_result['crack_time_display']
      expect(ruby_result.score).to eq js_result['score']
      expect(ruby_result.pattern).to eq js_result['pattern']
      expect(ruby_result.match_sequence.count).to eq js_result['match_sequence'].count

      # NOTE: feedback didn't exist in the version of the JS library this gem
      #       is based on, so instead we just check that it put `Feedback` in
      #       there. Real tests for its values go in `feedback_giver_spec.rb`.
      expect(ruby_result.feedback).to be_a Zxcvbn::Feedback
    end
  end

  context 'with a custom user dictionary' do
    it 'scores them against the user dictionary' do
      result = tester.test('themeforest', ['themeforest'])
      expect(result.entropy).to eq 0
      expect(result.score).to eq 0
    end

    it 'matches l33t substitutions on this dictionary' do
      result = tester.test('th3m3for3st', ['themeforest'])
      expect(result.entropy).to eq 1
      expect(result.score).to eq 0
    end
  end

  context 'with a custom global dictionary' do
    before { tester.add_word_lists('envato' => ['envato']) }

    it 'scores them against the dictionary' do
      result = tester.test('envato')
      expect(result.entropy).to eq 0
      expect(result.score).to eq 0
    end
  end

  context 'nil password' do
    specify do
      expect { tester.test(nil) }.to_not raise_error
    end
  end
end