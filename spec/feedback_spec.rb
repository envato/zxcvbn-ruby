require 'spec_helper'

SequenceToken = Struct.new(:token, :pattern)

describe Zxcvbn::Feedback do

  let(:feedback_result) { Zxcvbn::Feedback.new(score, sequence).suggestions }

  context "score and squence are low or non existent (most likly no password tested)" do
    let(:score) { 0 }
    let(:sequence) { [] }

    it "returns a struct with warning and suggestions" do
      expect(feedback_result.to_h).to have_key(:warning)
      expect(feedback_result.to_h).to have_key(:suggestions)
    end
  end

  context "weak password" do
    let(:score) { 0 }
    let(:sequence) do
      [
        SequenceToken.new("I", "dictionary"),
        SequenceToken.new("LOVE", "bruteforce"),
        SequenceToken.new("cats", "dictionary"),
      ]
    end

    it "returns suggestions with weak password" do
      expect(feedback_result.suggestions).to_not be_empty
    end
  end

  context "secure password" do
    let(:score) { 4 }
    let(:sequence) do
      [
        SequenceToken.new("cats", "dictionary"),
        SequenceToken.new(".", "bruteforce"),
        SequenceToken.new("look", "dictionary"),
        SequenceToken.new(".", "bruteforce"),
        SequenceToken.new("good", "dictionary"),
        SequenceToken.new(".", "bruteforce"),
        SequenceToken.new("in", "dictionary"),
        SequenceToken.new(".", "bruteforce"),
        SequenceToken.new("black", "dictionary"),
      ]
    end

    it "returns empty suggestions if score is above 2" do
      expect(feedback_result.suggestions).to be_empty
    end
  end
end
