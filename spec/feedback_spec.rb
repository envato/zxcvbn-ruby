require 'spec_helper'
describe Zxcvbn::Feedback do

  let(:feedback_result) { Zxcvbn::Feedback.new(score, sequence).suggestions }

  context "score and squence are low or non existent (most likly tested an empty string)" do
    let(:score) { 0 }
    let(:sequence) { [] }

    it "returns an object with warning and suggestions" do
      expect(feedback_result).to respond_to(:warning)
      expect(feedback_result).to respond_to(:suggestions)
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
        double("password token", :token => "I", :pattern => "dictionary"),
        double("password token", :token => "LOVE", :pattern => "bruteforce"),
        double("password token", :token => "cats", :pattern => "dictionary")
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
        double("password token", :token => "cats", :pattern => "dictionary"),
        double("password token", :token => ".", :pattern => "bruteforce"),
        double("password token", :token => "look", :pattern => "dictionary"),
        double("password token", :token => ".", :pattern => "bruteforce"),
        double("password token", :token => "good", :pattern => "dictionary"),
        double("password token", :token => ".", :pattern => "bruteforce"),
        double("password token", :token => "in", :pattern => "dictionary"),
        double("password token", :token => ".", :pattern => "bruteforce"),
        double("password token", :token => "black", :pattern => "dictionary"),
      ]
    end

    it "returns empty suggestions if score is above 2" do
      expect(feedback_result.suggestions).to be_empty
    end
  end

  context "spatal" do
    let(:score) { 0 }
    let(:sequence) { [double("password token", :token => "yuiop", :pattern => "spatial")] }

    it "suggests not using spatially similar keyboard characters" do
      expect(feedback_result.suggestions).to include("Use a longer keyboard pattern with more turns")
    end

    it "has a warning regarding keyboard patterns" do
      expect(feedback_result.warning).to eq("Short keyboard patterns are easy to guess")
    end
  end

  context "repeat" do
    let(:score) { 0 }
    let(:sequence) { [double("password token", :token => "hhhhhh", :pattern => "repeat")] }

    it "suggests not using repeating characters" do
      expect(feedback_result.suggestions).to include("Avoid repeated words, characters and numbers")
    end

    it "has a warning regarding character repetition" do
      expect(feedback_result.warning).to eq("Repeats like 'aaa' or 'abcabcabc' are easy to guess")
    end
  end

  context "sequence" do
    let(:score) { 0 }
    let(:sequence) { [double("password token", :token => "abcdef", :pattern => "sequence")] }

    it "suggests not using repeating characters" do
      expect(feedback_result.suggestions).to include("Avoid sequences")
    end

    it "has a warning regarding character repetition" do
      expect(feedback_result.warning).to eq("Sequences like abc or 6543 are easy to guess")
    end
  end

  context "year" do
    let(:score) { 0 }
    let(:sequence) { [double("password token", :token => "2014", :pattern => "year")] }

    it "suggests not using repeating characters" do
      expect(feedback_result.suggestions).to include("Avoid recent years or years that are associated with you")
    end

    it "has a warning regarding character repetition" do
      expect(feedback_result.warning).to eq("Years are easy to guess")
    end
  end

  context "dictionary" do
    context "password" do
      let(:score) { 0 }
      let(:sequence) { [double(
        "Sequence Token",
        :token => "baseball",
        :pattern => "dictionary",
        :dictionary_name => "passwords",
        :l33t_entropy => 0,
        :uppercase_entropy => 0)]
      }

      it "warns about known common passwords" do
        expect(feedback_result.warning).to eq("This is similar to a commonly used password")
      end
    end

    context "english" do
      let(:score) { 0 }
      let(:sequence) { [double(
        "Sequence Token",
        :token => "something",
        :pattern => "dictionary",
        :dictionary_name => "english",
        :l33t_entropy => 0,
        :uppercase_entropy => 0)]
      }

      it "warns about common english words" do
        expect(feedback_result.warning).to eq("Simple passwords with a few comomon words are easy to guess")
      end
    end

    context "names" do
      let(:score) { 0 }
      let(:sequence) { [double(
        "Sequence Token",
        :token => "betty",
        :pattern => "dictionary",
        :dictionary_name => "female_names",
        :l33t_entropy => 0,
        :uppercase_entropy => 0)]
      }

      it "warns about using common names" do
        expect(feedback_result.warning).to eq("Common names and surnames are easy to guess")
      end
    end
  end

  context "l33t substitutions" do
    let(:score) { 0 }
    let(:sequence) { [double(
      "Sequence Token",
      :token => "P@SSWORD",
      :pattern => "dictionary",
      :dictionary_name => "passwords",
      :l33t_entropy => 1,
      :uppercase_entropy => 0)]
    }

    it "suggests leet character substitutions don't help to increase complexity" do
      expect(feedback_result.suggestions).to include("Predictable substitutions like '@' instead of 'a' don't help very much")
    end
  end

  context "capitalizations" do
    let(:score) { 0 }
    let(:sequence) { [double(
      "Sequence Token",
      :token => "Cats",
      :pattern => "dictionary",
      :dictionary_name => "english",
      :l33t_entropy => 0,
      :uppercase_entropy => 1)]
    }

    it "suggests capitalizations don't help to increase complexity" do
      expect(feedback_result.suggestions).to include("Capitalization doesn't help very much")
    end
  end
end
