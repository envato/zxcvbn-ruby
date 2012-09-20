require 'spec_helper'

describe Zxcvbn::Matching::L33t do
  let(:matcher) { described_class.new([dictionary_matcher]) }
  let(:dictionary) { Zxcvbn::RANKED_DICTIONARIES['english'] }
  let(:dictionary_matcher) { Zxcvbn::Matching::Dictionary.new(dictionary) }

  describe '#relevant_l33t_substitutions' do
    it 'returns relevant l33t substitutions' do
      matcher.relevant_l33t_substitutions('p@ssw1rd24').should eq(
        {'a' => ['@', '4'], 'i' => ['1'], 'l' => ['1'], 'z' => ['2']}
      )
    end
  end

  describe 'possible l33t substitutions' do
    context 'with 2 possible substitutions' do
      it 'returns the correct possible substitutions' do
        substitutions = {'a' => ['@'], 'i' => ['1']}
        matcher.substitution_combinations(substitutions).should match_array([
          {'a' => '@'},
          {'i' => '1'},
          {'a' => '@', 'i' => '1'}
        ])
      end

      it 'returns the correct possible substitutions with multiple options' do
        substitutions = {'a' => ['@', '4'], 'i' => ['1']}
        matcher.substitution_combinations(substitutions).should match_array([
          {'a' => '@'},
          {'i' => '1'},
          {'a' => '4'},
          {'a' => '@', 'i' => '1'},
          {'a' => '4', 'i' => '1'}
        ])
      end
    end

    context 'with 3 possible substitutions' do
      it 'returns the correct possible substitutions' do
        substitutions = {'a' => ['@'], 'i' => ['1'], 'z' => ['3']}
        matcher.substitution_combinations(substitutions).should match_array([
          {'a' => '@'},
          {'i' => '1'},
          {'z' => '3'},
          {'a' => '@', 'i' => '1'},
          {'a' => '@', 'z' => '3'},
          {'z' => '3', 'i' => '1'},
          {'a' => '@', 'i' => '1', 'z' => '3'}
        ])
      end
    end

    context 'with 4 possible substitutions' do
      it 'returns the correct possible substitutions' do
        substitutions = {'a' => ['@'], 'i' => ['1'], 'z' => ['3'], 'b' => ['8']}
        matcher.substitution_combinations(substitutions).should match_array([
          {'a' => '@'},
          {'i' => '1'},
          {'z' => '3'},
          {'b' => '8'},
          {'a' => '@', 'i' => '1'},
          {'a' => '@', 'z' => '3'},
          {'z' => '3', 'i' => '1'},
          {'a' => '@', 'b' => '8'},
          {'i' => '1', 'b' => '8'},
          {'z' => '3', 'b' => '8'},
          {'a' => '@', 'i' => '1', 'z' => '3'},
          {'a' => '@', 'i' => '1', 'b' => '8'},
          {'a' => '@', 'z' => '3', 'b' => '8'},
          {'i' => '1', 'z' => '3', 'b' => '8'},
          {'a' => '@', 'i' => '1', 'z' => '3', 'b' => '8'}
        ])
      end
    end
  end

  describe '#matches' do
    let(:matches) { matcher.matches('p@ssword') }

    it 'finds the correct matches' do
      matches.map(&:matched_word).should eq([
        'pas',
        'a',
        'as',
        'ass'
      ])
    end

    it 'sets the token correctly on those matches' do
      matches.map(&:token).should eq([
        'p@s',
        '@',
        '@s',
        '@ss'
      ])
    end

    it 'sets the substituions used' do
      matches.map(&:sub).should eq([
        {'a' => '@'},
        {'a' => '@'},
        {'a' => '@'},
        {'a' => '@'}
      ])
    end
  end

  context 'integration with all dictionaries' do
    let(:matcher) { described_class.new(dictionary_matchers) }
    let(:dictionary_matchers) {
      Zxcvbn::RANKED_DICTIONARIES.values.map do |dictionary|
        Zxcvbn::Matching::Dictionary.new(dictionary)
      end
    }

    def l33t_match(password, dictionary)
      method_invoker.eval_convert_object(%'l33t_match("#{password}", build_ranked_dict(#{dictionary}))')
    end

    %w[ viking briansmith4mayor ].each do |password|
      it "gives back the same results for #{password}" do
        js_results = l33t_match(password, 'english')
        ruby_results = matcher.matches(password)
        js_results.map{|r| r['matched_word']}.should match_array(ruby_results.map(&:matched_word))
        js_results.count.should eq ruby_results.count
      end
    end
  end
end