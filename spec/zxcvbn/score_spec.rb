# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Score do
  let(:minimal) do
    described_class.new(
      password: 'test',
      guesses: 100.0,
      sequence: [],
      crack_times_seconds: {},
      crack_times_display: {},
      score: 0
    )
  end

  it 'defaults calc_time to nil' do
    expect(minimal.calc_time).to be_nil
  end

  it 'defaults feedback to nil' do
    expect(minimal.feedback).to be_nil
  end

  describe '#guesses_log10' do
    it 'returns log10 of guesses' do
      expect(minimal.guesses_log10).to be_within(1e-10).of(Math.log10(100.0))
    end

    it 'returns nil when guesses is nil' do
      score = minimal.with(guesses: nil)
      expect(score.guesses_log10).to be_nil
    end
  end

  describe '#inspect' do
    it 'does not include the password' do
      expect(minimal.inspect).not_to include('test')
    end

    it 'includes other non-nil fields' do
      expect(minimal.inspect).to include('score=0')
    end
  end

  it 'supports structural equality' do
    other = described_class.new(
      password: 'test',
      guesses: 100.0,
      sequence: [],
      crack_times_seconds: {},
      crack_times_display: {},
      score: 0
    )
    expect(minimal).to eq other
  end
end
