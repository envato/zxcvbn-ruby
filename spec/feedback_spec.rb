require 'spec_helper'

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
        {token: "I", pattern: "dictionary"},
        {token: "LOVE", pattern: "bruteforce"},
        {token: "cats", pattern: "dictionary"},
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
        {token: "cats", pattern: "dictionary"},
        {token: ".", pattern: "bruteforce"},
        {token: "look", pattern: "dictionary"},
        {token: ".", pattern: "bruteforce"},
        {token: "good", pattern: "dictionary"},
        {token: ".", pattern: "bruteforce"},
        {token: "in", pattern: "dictionary"},
        {token: ".", pattern: "bruteforce"},
        {token: "black", pattern: "dictionary"},
      ]
    end

    it "returns empty suggestions if score is above 2" do
      expect(feedback_result.suggestions).to be_empty
    end
  end
end
