require 'spec_helper'

describe 'Zxcvbn.test' do
  context 'with a password' do
    it 'returns a result' do
      result = Zxcvbn.test('password')
      expect(result.entropy).to_not be_nil
    end
  end

  context 'with a password and user input' do
    it 'returns a result' do
      result = Zxcvbn.test('password', ['inputs'])
      expect(result.entropy).to_not be_nil
    end
  end

  context 'with a password, user input and custom word lists' do
    it 'returns a result' do
      result = Zxcvbn.test('password', ['inputs'], {'list' => ['words']})
      expect(result.entropy).to_not be_nil
    end
  end
end
