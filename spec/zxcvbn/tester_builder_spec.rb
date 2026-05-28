# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::TesterBuilder do
  describe 'Zxcvbn.tester_builder' do
    it 'returns a Builder' do
      expect(Zxcvbn.tester_builder).to be_a(Zxcvbn::TesterBuilder)
    end

    it 'returns a new Builder on each call' do
      expect(Zxcvbn.tester_builder).not_to be(Zxcvbn.tester_builder)
    end
  end

  describe '#build' do
    it 'returns a Tester' do
      expect(Zxcvbn.tester_builder.build).to be_a(Zxcvbn::Tester)
    end

    it 'returns a frozen Tester' do
      expect(Zxcvbn.tester_builder.build).to be_frozen
    end

    it 'uses the default max_password_length when none is set' do
      expect(Zxcvbn.tester_builder.build.max_password_length).to eq Zxcvbn::TesterBuilder::DEFAULT_MAX_PASSWORD_LENGTH
    end

    it 'raises ArgumentError when ZXCVBN_MAX_PASSWORD_LENGTH is not an integer' do
      stub_const('ENV', { 'ZXCVBN_MAX_PASSWORD_LENGTH' => 'abc' })
      expect { Zxcvbn.tester_builder.build }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError when ZXCVBN_MAX_PASSWORD_LENGTH is non-positive' do
      stub_const('ENV', { 'ZXCVBN_MAX_PASSWORD_LENGTH' => '0' })
      expect { Zxcvbn.tester_builder.build }.to raise_error(ArgumentError)
    end

    it 'reads max_password_length from ZXCVBN_MAX_PASSWORD_LENGTH when none is set' do
      stub_const('ENV', { 'ZXCVBN_MAX_PASSWORD_LENGTH' => '50' })
      expect(Zxcvbn.tester_builder.build.max_password_length).to eq 50
    end

    it 'parses ZXCVBN_MAX_PASSWORD_LENGTH as base 10, not octal' do
      stub_const('ENV', { 'ZXCVBN_MAX_PASSWORD_LENGTH' => '010' })
      expect(Zxcvbn.tester_builder.build.max_password_length).to eq 10
    end

    it 'ignores ZXCVBN_MAX_PASSWORD_LENGTH when an explicit value is set' do
      stub_const('ENV', { 'ZXCVBN_MAX_PASSWORD_LENGTH' => '50' })
      expect(Zxcvbn.tester_builder.max_password_length(10).build.max_password_length).to eq 10
    end

    it 'honours a custom max_password_length' do
      tester = Zxcvbn.tester_builder.max_password_length(10).build
      expect { tester.test('a' * 10) }.not_to raise_error
      expect { tester.test('a' * 11) }.to raise_error(Zxcvbn::PasswordTooLong)
    end

    it 'applies an added word list' do
      tester = Zxcvbn.tester_builder.add_word_list('envato', ['envato']).build
      expect(tester.test('envato').score).to eq 0
    end

    it 'returns independent testers on each build' do
      builder = Zxcvbn.tester_builder
      expect(builder.build).not_to be(builder.build)
    end

    it 'raises ArgumentError for non-positive max_password_length' do
      expect { Zxcvbn.tester_builder.max_password_length(0) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError for nil max_password_length' do
      expect { Zxcvbn.tester_builder.max_password_length(nil) }.to raise_error(ArgumentError)
    end

    it 'treats nil words in add_word_list the same as an empty array' do
      tester = Zxcvbn.tester_builder.add_word_list('test', nil).build
      expect(tester.test('envato').guesses).to eq ZXCVBN_TESTER.test('envato').guesses
    end

    it 'accepts a single String in add_word_list' do
      tester = Zxcvbn.tester_builder.add_word_list('envato', 'envato').build
      expect(tester.test('envato').guesses).to be < ZXCVBN_TESTER.test('envato').guesses
    end

    it 'ignores non-String entries in add_word_list' do
      tester_with_symbol = Zxcvbn.tester_builder.add_word_list('mixed', [:envato]).build
      expect(tester_with_symbol.test('envato').guesses).to eq ZXCVBN_TESTER.test('envato').guesses
    end

    it 'accumulates multiple add_word_list calls' do
      tester = Zxcvbn.tester_builder
                     .add_word_list('a', ['foo'])
                     .add_word_list('b', ['bar'])
                     .build
      expect(tester.test('foo').score).to eq 0
      expect(tester.test('bar').score).to eq 0
    end
  end

  describe 'method chaining' do
    it 'add_word_list returns self' do
      builder = Zxcvbn.tester_builder
      expect(builder.add_word_list('x', [])).to be(builder)
    end

    it 'max_password_length returns self' do
      builder = Zxcvbn.tester_builder
      expect(builder.max_password_length(10)).to be(builder)
    end
  end
end
