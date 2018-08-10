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

    it "dfaults with some sane suggestions" do
      expect(feedback_result.suggestions).to include("Use a few words, avoid common phrases")
      expect(feedback_result.suggestions).to include("No need for symbols, digits, or uppercase letters")
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

  context "spatal" do
    let(:score) { 0 }
    let(:sequence) { [SequenceToken.new("yuiop", "spatial")] }

    it "suggests not using spatially similar keyboard characters" do
      expect(feedback_result.suggestions).to include("Use a longer keyboard pattern with more turns")
    end

    it "has a warning regarding keyboard patterns" do
      expect(feedback_result.warning).to eq("Short keyboard patterns are easy to guess")
    end
  end

  context "repeat" do
    let(:score) { 0 }
    let(:sequence) { [SequenceToken.new("hhhhhh", "repeat")] }

    it "suggests not using repeating characters" do
      expect(feedback_result.suggestions).to include("Avoid repeated words and characters")
    end

    it "has a warning regarding character repetition" do
      expect(feedback_result.warning).to eq("Repeats like 'aaa' or 'abcabcabc' are easy to guess")
    end
  end

  context "sequence" do
    let(:score) { 0 }
    let(:sequence) { [SequenceToken.new("abcdef", "sequence")] }

    it "suggests not using repeating characters" do
      expect(feedback_result.suggestions).to include("Avoid sequences")
    end

    it "has a warning regarding character repetition" do
      expect(feedback_result.warning).to eq("Sequences like abc or 6543 are easy to guess")
    end
  end

  context "year" do
    let(:score) { 0 }
    let(:sequence) { [SequenceToken.new("2014", "year")] }

    it "suggests not using repeating characters" do
      expect(feedback_result.suggestions).to include("Avoid recent years or years that are associated with you")
    end

    it "has a warning regarding character repetition" do
      expect(feedback_result.warning).to eq("Years are easy to guess")
    end
  end
end
