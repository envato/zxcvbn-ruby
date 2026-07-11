# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::CaseHelpers do
  describe '.downcase_preserving_length' do
    it 'downcases ASCII strings' do
      expect(described_class.downcase_preserving_length('PassWord')).to eq 'password'
    end

    it 'keeps the character length when downcasing would grow the string' do
      lowercased = described_class.downcase_preserving_length('İpassword')
      expect(lowercased).to eq 'ipassword'
      expect(lowercased.length).to eq 'İpassword'.length
    end

    it 'downcases multibyte characters whose length is unaffected' do
      expect(described_class.downcase_preserving_length('✅ЖÜ')).to eq '✅жü'
    end
  end
end
