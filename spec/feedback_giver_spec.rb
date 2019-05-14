require 'spec_helper'

describe Zxcvbn::FeedbackGiver do
  # NOTE: We go in via the tester because the `FeedbackGiver` relies on both
  #       Omnimatch and the Scorer, which are troublesome to wire up for tests
  let(:tester) { Zxcvbn::Tester.new }

  describe '.get_feedback' do
    it "gives empty feedback when a password's score is good" do
      feedback = tester.test('5815A30BE798').feedback

      expect(feedback).to be_a Zxcvbn::Feedback
      expect(feedback.warning).to be_nil
      expect(feedback.suggestions).to be_empty
    end

    it 'gives general feedback when a password is empty' do
      feedback = tester.test('').feedback

      expect(feedback).to be_a Zxcvbn::Feedback
      expect(feedback.warning).to be_nil
      expect(feedback.suggestions).to contain_exactly(
        'Use a few words, avoid common phrases',
        'No need for symbols, digits, or uppercase letters'
      )
    end

    it "gives general feedback when a password is poor but doesn't match any heuristics" do
      feedback = tester.test(':005:0').feedback

      expect(feedback).to be_a Zxcvbn::Feedback
      expect(feedback.warning).to be_nil
      expect(feedback.suggestions).to contain_exactly(
        'Add another word or two. Uncommon words are better.'
      )
    end

    describe 'gives specific feedback' do
      describe 'for dictionary passwords' do
        it 'that are extremely common' do
          feedback = tester.test('password').feedback

          expect(feedback).to be_a Zxcvbn::Feedback
          expect(feedback.warning).to eql('This is a top-10 common password')
          expect(feedback.suggestions).to contain_exactly(
            'Add another word or two. Uncommon words are better.'
          )
        end

        it 'that are very, very common' do
          feedback = tester.test('letmein').feedback

          expect(feedback).to be_a Zxcvbn::Feedback
          expect(feedback.warning).to eql('This is a top-100 common password')
          expect(feedback.suggestions).to contain_exactly(
            'Add another word or two. Uncommon words are better.'
          )
        end

        it 'that are very common' do
          feedback = tester.test('playstation').feedback

          expect(feedback).to be_a Zxcvbn::Feedback
          expect(feedback.warning).to eql('This is a very common password')
          expect(feedback.suggestions).to contain_exactly(
            'Add another word or two. Uncommon words are better.'
          )
        end

        it 'that are common and you tried to use l33tsp33k' do
          feedback = tester.test('pl4yst4ti0n').feedback

          expect(feedback).to be_a Zxcvbn::Feedback
          expect(feedback.warning).to eql(
            'This is similar to a commonly used password'
          )
          expect(feedback.suggestions).to contain_exactly(
            'Add another word or two. Uncommon words are better.',
            "Predictable substitutions like '@' instead of 'a' don't help very much"
          )
        end

        it 'that are common and you capitalised the start' do
          feedback = tester.test('Password').feedback

          expect(feedback).to be_a Zxcvbn::Feedback
          expect(feedback.warning).to eql(
            'This is a top-10 common password'
          )
          expect(feedback.suggestions).to contain_exactly(
            'Add another word or two. Uncommon words are better.',
            "Capitalization doesn't help very much"
          )
        end

        it 'that are common and you capitalised the whole thing' do
          feedback = tester.test('PASSWORD').feedback

          expect(feedback).to be_a Zxcvbn::Feedback
          expect(feedback.warning).to eql(
            'This is a top-10 common password'
          )
          expect(feedback.suggestions).to contain_exactly(
            'Add another word or two. Uncommon words are better.',
            'All-uppercase is almost as easy to guess as all-lowercase'
          )
        end

        it 'that contain a common first name or last name' do
          feedback = tester.test('jessica').feedback

          expect(feedback).to be_a Zxcvbn::Feedback
          expect(feedback.warning).to eql(
            'Names and surnames by themselves are easy to guess'
          )
          expect(feedback.suggestions).to contain_exactly(
            'Add another word or two. Uncommon words are better.'
          )

          feedback = tester.test('smith').feedback

          expect(feedback).to be_a Zxcvbn::Feedback
          expect(feedback.warning).to eql(
            'Names and surnames by themselves are easy to guess'
          )
          expect(feedback.suggestions).to contain_exactly(
            'Add another word or two. Uncommon words are better.'
          )
        end

        it 'that contain a common name and surname' do
          feedback = tester.test('jessica smith').feedback

          expect(feedback).to be_a Zxcvbn::Feedback
          expect(feedback.warning).to eql(
            'Common names and surnames are easy to guess'
          )
          expect(feedback.suggestions).to contain_exactly(
            'Add another word or two. Uncommon words are better.'
          )
        end
      end

      describe 'for spatial passwords' do
        it 'that contain a straight keyboard row' do
          feedback = tester.test('1qaz').feedback

          expect(feedback).to be_a Zxcvbn::Feedback
          expect(feedback.warning).to eql(
            'Straight rows of keys are easy to guess'
          )
          expect(feedback.suggestions).to contain_exactly(
            'Add another word or two. Uncommon words are better.',
            'Use a longer keyboard pattern with more turns'
          )
        end

        it 'that contain a keyboard pattern with one turn' do
          feedback = tester.test('zaqwer').feedback

          expect(feedback).to be_a Zxcvbn::Feedback
          expect(feedback.warning).to eql(
            'Short keyboard patterns are easy to guess'
          )
          expect(feedback.suggestions).to contain_exactly(
            'Add another word or two. Uncommon words are better.',
            'Use a longer keyboard pattern with more turns'
          )
        end
      end

      it 'for passwords with repeated characters' do
        feedback = tester.test('zzz').feedback

        expect(feedback).to be_a Zxcvbn::Feedback
        expect(feedback.warning).to eql(
          'Repeats like "aaa" are easy to guess'
        )
        expect(feedback.suggestions).to contain_exactly(
          'Add another word or two. Uncommon words are better.',
          'Avoid repeated words and characters'
        )
      end

      it 'for passwords with sequential characters' do
        feedback = tester.test('pqrpqrpqr').feedback

        expect(feedback).to be_a Zxcvbn::Feedback
        expect(feedback.warning).to eql(
          'Sequences like abc or 6543 are easy to guess'
        )
        expect(feedback.suggestions).to contain_exactly(
          'Add another word or two. Uncommon words are better.',
          'Avoid sequences'
        )
      end

      it 'for passwords containing dates' do
        feedback = tester.test('testing02\12\1997').feedback

        expect(feedback).to be_a Zxcvbn::Feedback
        expect(feedback.warning).to eql(
          'Dates are often easy to guess'
        )
        expect(feedback.suggestions).to contain_exactly(
          'Add another word or two. Uncommon words are better.',
          'Avoid dates and years that are associated with you'
        )
      end
    end
  end
end
