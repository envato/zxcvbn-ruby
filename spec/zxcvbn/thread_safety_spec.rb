# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Thread safety' do
  let(:tester) { ZXCVBN_TESTER }

  describe 'concurrent Zxcvbn.test from N threads' do
    it 'returns consistent results' do
      threads = Array.new(5) { Thread.new { Zxcvbn.test('password') } }
      results = threads.map(&:value)

      expect(results.map(&:guesses).uniq).to eq [results.first.guesses]
      expect(results.map(&:score).uniq).to eq [results.first.score]
    end
  end

  describe 'FrozenError on nested collections' do
    let(:result) { tester.test('correcthorsebatterystaple') }

    specify 'sequence is frozen' do
      expect { result.sequence.push(nil) }.to raise_error(FrozenError)
    end

    specify 'crack_times_seconds is frozen' do
      expect { result.crack_times_seconds['online_throttling_100_per_hour'] = 0 }.to raise_error(FrozenError)
    end

    specify 'crack_times_display is frozen' do
      expect { result.crack_times_display['online_throttling_100_per_hour'] = 'evil' }.to raise_error(FrozenError)
    end

    specify 'feedback suggestions is frozen' do
      expect { result.feedback.suggestions.push('evil') }.to raise_error(FrozenError)
    end

    specify 'DEFAULT_FEEDBACK suggestions is frozen' do
      expect { Zxcvbn::FeedbackGiver::DEFAULT_FEEDBACK.suggestions.push('evil') }.to raise_error(FrozenError)
    end

    specify 'match sub hash is frozen' do
      l33t_result = tester.test('p@ssword')
      l33t_match = l33t_result.sequence.find(&:sub)
      skip 'no l33t match found' unless l33t_match

      expect { l33t_match.sub['@'] = 'EVIL' }.to raise_error(FrozenError)
    end
  end

  describe 'concurrent default_tester initialization' do
    around do |example|
      saved = Zxcvbn.instance_variable_get(:@default_tester)
      Zxcvbn.instance_variable_set(:@default_tester, nil)
      example.run
    ensure
      Zxcvbn.instance_variable_set(:@default_tester, saved)
    end

    it 'initializes exactly one shared tester under concurrent pressure' do
      testers = Array.new(5) { Thread.new { Zxcvbn.send(:default_tester) } }.map(&:value)
      expect(testers.uniq.length).to eq 1
    end
  end
end
