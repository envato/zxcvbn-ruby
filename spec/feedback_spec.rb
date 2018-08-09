require 'spec_helper'

describe Zxcvbn::Feedback do

  let(:suggestions) { Zxcvbn::Feedback.new(score, sequence).suggestions }
  # let(:score) { Zxcvbn::Score.new(score_options) }
  let(:score) { 0 }

  let(:sequence) do
    [
      {token: "p@ssword", pattern: "dictionary"},
      {token: "2001", pattern: "year"}
    ]
  end

  it "returns a struct with warning and suggestions" do
    expect(suggestions.to_h).to have_key(:warning)
    expect(suggestions.to_h).to have_key(:suggestions)
  end

end
