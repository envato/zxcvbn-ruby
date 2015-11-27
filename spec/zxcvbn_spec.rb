require 'spec_helper'

describe 'Zxcvbn.test' do
  context 'with a password' do
    it 'returns a result' do
      result = Zxcvbn.test('password')
      expect(result.score).to_not be_nil
    end
  end

  context "with a password" do
    it 'returns 0 with an easy password' do
      result = Zxcvbn.test('password', ['inputs'])
      expect(result.score).to eq 0
    end

    it 'returns 4 with a hard to guess password' do
      result = Zxcvbn.test('vkeuvuxkskf37w')
      expect(result.score).to eq 4
    end
  end

  context 'with a password and user inputs' do
    it 'returns 4 with a hard to guess password that is not an input' do
      result = Zxcvbn.test('vkeuvuxkskf37w', ['my name'])
      expect(result.score).to eq 4
    end

    it 'returns 0 with a hard to guess password that is part of the input' do
      result = Zxcvbn.test('vkeuvuxkskf37w', ['my name', 'vkeuvuxkskf37w'])
      expect(result.score).to eq 0
    end
  end

  context 'with js injection' do
    it 'prevents js injection in password' do
      result = Zxcvbn.test("'\"\n;")
      expect(result.score).to eq 1
    end

    it 'prevents js injection in user input list ' do
      result = Zxcvbn.test("password", ["'\"\n;", "'", "["])
      expect(result.score).to eq 0
    end
  end
end
