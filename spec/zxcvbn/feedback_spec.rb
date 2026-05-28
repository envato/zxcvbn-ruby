# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Feedback do
  it 'defaults warning to an empty string' do
    expect(described_class.new.warning).to eq ''
  end

  it 'coerces nil warning to an empty string' do
    expect(described_class.new(warning: nil).warning).to eq ''
  end

  it 'defaults suggestions to an empty array' do
    expect(described_class.new.suggestions).to eq []
  end

  it 'freezes suggestions' do
    expect(described_class.new(suggestions: ['foo']).suggestions).to be_frozen
  end

  it 'supports structural equality' do
    a = described_class.new(warning: 'w', suggestions: ['s'])
    b = described_class.new(warning: 'w', suggestions: ['s'])
    expect(a).to eq b
  end
end
