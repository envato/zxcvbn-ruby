# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Zxcvbn.test' do
  context 'with a password' do
    it 'returns a result' do
      result = Zxcvbn.test('password')
      expect(result.guesses).to_not be_nil
    end
  end

  context 'with a password and user input' do
    it 'returns a result' do
      result = Zxcvbn.test('password', ['inputs'])
      expect(result.guesses).to_not be_nil
    end
  end

  context 'with a password, user input and custom word lists' do
    it 'returns a result' do
      result = Zxcvbn.test('password', ['inputs'], { 'list' => ['words'] })
      expect(result.guesses).to_not be_nil
    end
  end

  context 'with a password over the length limit' do
    let(:over_limit) { 'a' * (Zxcvbn::Tester::MAX_PASSWORD_LENGTH + 1) }

    it 'raises PasswordTooLong via the shared default tester' do
      expect { Zxcvbn.test(over_limit) }.to raise_error(Zxcvbn::PasswordTooLong)
    end

    it 'raises PasswordTooLong via a fresh tester when word_lists are supplied' do
      expect { Zxcvbn.test(over_limit, [], { 'custom' => ['word'] }) }.to raise_error(Zxcvbn::PasswordTooLong)
    end
  end
end
