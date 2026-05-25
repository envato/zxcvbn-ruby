# frozen_string_literal: true

require 'spec_helper'
require 'benchmark'

RSpec.describe Zxcvbn::Tester do
  let(:tester) { Zxcvbn::Tester.new }

  context 'JS compatibility' do
    before(:context) { @shared_tester = Zxcvbn::Tester.new }
    let(:tester) { @shared_tester }

    TEST_PASSWORDS.each do |password|
      it "matches the JS result for #{password}" do
        ruby_result = tester.test(password)
        js_result = js_zxcvbn(password)

        expect(ruby_result.calc_time).not_to be_nil
        expect(ruby_result.password).to eq js_result['password']
        expect(ruby_result.score).to eq js_result['score']
        expect(ruby_result.sequence.count).to eq js_result['sequence'].count

        expect(ruby_result.guesses_log10).to be_within(0.01).of(js_result['guesses_log10'])

        ruby_result.sequence.zip(js_result['sequence']).each_with_index do |(ruby_match, js_match), idx|
          # Ruby uses 'year' where JS v4 uses 'regex' (regex_name: 'recent_year') — intentional naming difference.
          ruby_pattern = ruby_match.pattern == 'year' ? 'regex' : ruby_match.pattern
          expect(ruby_pattern).to eq(js_match['pattern']), "match #{idx} pattern mismatch"
          expect(ruby_match.i).to eq(js_match['i']), "match #{idx} i mismatch"
          expect(ruby_match.j).to eq(js_match['j']), "match #{idx} j mismatch"
        end

        expect(ruby_result.feedback.warning).to eq js_result['feedback']['warning']
        expect(ruby_result.feedback.suggestions).to eq js_result['feedback']['suggestions']
      end
    end
  end

  context 'with a custom user dictionary' do
    it 'scores them against the user dictionary' do
      result = tester.test('themeforest', ['themeforest'])
      expect(result.score).to eq 0
    end

    it 'matches l33t substitutions on this dictionary' do
      result = tester.test('th3m3for3st', ['themeforest'])
      expect(result.score).to eq 0
    end

    it 'catches reversed user-input words' do
      result = tester.test('tserofemeht', ['themeforest'])
      expect(result.score).to eq 0
      expect(result.sequence.any?(&:reversed)).to be true
    end

    it 'scores repeats of user-input words using user context' do
      with_inputs    = tester.test('themeforestthemeforest', ['themeforest'])
      without_inputs = tester.test('themeforestthemeforest', [])
      expect(with_inputs.guesses).to be < without_inputs.guesses
    end
  end

  context 'with Unicode entries in the password' do
    it 'validates the password' do
      result = tester.test('✅🐴🔋staple', %w[Theme Forest themeforest])
      expect(result.guesses).to be_positive
      expect(result.score).to be_positive
    end
  end

  context 'with Unicode entries in the dictionary' do
    it 'validates the password' do
      result = tester.test('correct horse battery staple', %w[✅ 🐴 🔋])
      expect(result.guesses).to be_positive
      expect(result.score).to be_positive
    end
  end

  context 'with Unicode entries in the password and the dictionary' do
    it 'validates the password' do
      result = tester.test('✅🐴🔋staple', %w[✅ 🐴 🔋])
      expect(result.guesses).to be_positive
    end
  end

  context 'with invalid entries in the dictionary' do
    it 'ignores those entries' do
      result = tester.test('themeforest', [nil, 1, 'themeforest'])
      expect(result.score).to eq 0
    end
  end

  context 'with a custom global dictionary' do
    before { tester.add_word_lists('envato' => ['envato']) }

    it 'scores them against the dictionary' do
      result = tester.test('envato')
      expect(result.score).to eq 0
    end

    context 'with invalid entries in a custom dictionary' do
      before { tester.add_word_lists('themeforest' => [nil, 1, 'themeforest']) }

      it 'ignores those entries' do
        expect(tester.test('themeforest')).to have_attributes(score: 0)
      end
    end
  end

  context 'nil password' do
    specify do
      expect(tester.test(nil)).to have_attributes(guesses: 1, score: 0)
    end
  end

  context 'with a very long password' do
    it 'scores the full password without truncation' do
      long = 'a' * 400
      result = tester.test(long)
      expect(result.password.length).to eq 400
    end

    it 'completes in reasonable time for adversarial repeat inputs' do
      adversarial = 'ab' * 128
      elapsed = Benchmark.realtime { tester.test(adversarial) }
      expect(elapsed).to be < 5
    end

    it 'produces finite crack times for passwords longer than 308 characters' do
      # 'z' * 400 hits the repeat matcher (guesses ~4801), not bruteforce.
      # Use a high-entropy string so the whole password is a single bruteforce
      # match: length 400 → 10**400 → Float::MAX → crack time overflows to Infinity.
      saved = srand(7)
      high_entropy = (1..400).map { rand(33..126).chr }.join
      srand(saved)
      result = tester.test(high_entropy)
      expect(result.crack_times_seconds.values).to all(be_finite)
    end
  end
end
