# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zxcvbn::Guesses do
  # Minimal host that satisfies the Guesses mixin contract.
  # spatial_guesses additionally requires #data to supply graph stats,
  # which is covered through integration tests in tester_spec.rb.
  let(:host) do
    Class.new do
      include Zxcvbn::Guesses
      attr_reader :data

      def initialize(data = nil)
        @data = data
      end
    end.new
  end

  def make_match(**attrs)
    Zxcvbn::Match.new(**attrs)
  end

  describe '#bruteforce_guesses' do
    it 'applies the single-char floor for a one-character token' do
      m = make_match(token: 'a')
      # 10^1 = 10 < floor of 11 (MIN_SUBMATCH_GUESSES_SINGLE_CHAR + 1)
      expect(host.bruteforce_guesses(m)).to eq 11
    end

    it 'returns 10^n when that exceeds the multi-char floor' do
      m = make_match(token: 'abc')
      expect(host.bruteforce_guesses(m)).to eq 1000
    end
  end

  describe '#repeat_guesses' do
    it 'multiplies base_guesses by repeat_count' do
      m = make_match(base_guesses: 10, repeat_count: 3)
      expect(host.repeat_guesses(m)).to eq 30
    end
  end

  describe '#sequence_guesses' do
    it 'uses base 4 for common sequence starters' do
      %w[a A z Z 0 1 9].each do |char|
        m = make_match(token: char * 4, ascending: true)
        expect(host.sequence_guesses(m)).to eq(4 * 4), "expected base 4 for '#{char}'"
      end
    end

    it 'uses base 10 for other digit starters' do
      m = make_match(token: '234', ascending: true)
      expect(host.sequence_guesses(m)).to eq 10 * 3
    end

    it 'uses base 26 for non-digit non-special letter starters' do
      m = make_match(token: 'bcd', ascending: true)
      expect(host.sequence_guesses(m)).to eq 26 * 3
    end

    it 'doubles the base for descending sequences' do
      m = make_match(token: 'aaaa', ascending: false)
      expect(host.sequence_guesses(m)).to eq 4 * 2 * 4
    end
  end

  describe '#digits_guesses' do
    it 'returns 10 raised to the token length' do
      expect(host.digits_guesses(make_match(token: '1234'))).to eq 10_000
      expect(host.digits_guesses(make_match(token: '123456'))).to eq 1_000_000
    end
  end

  describe '#year_guesses' do
    let(:current_year) { Time.now.year }

    it 'returns the distance from the current year' do
      m = make_match(token: (current_year - 30).to_s)
      expect(host.year_guesses(m)).to eq 30
    end

    it 'applies a minimum distance of MIN_YEAR_SPACE (20)' do
      m = make_match(token: (current_year - 5).to_s)
      expect(host.year_guesses(m)).to eq 20
    end
  end

  describe '#date_guesses' do
    let(:current_year) { Time.now.year }
    let(:far_year) { current_year - 30 }

    it 'returns 365 * year_space when no separator is present' do
      m = make_match(year: far_year, separator: '')
      expect(host.date_guesses(m)).to eq 365 * 30
    end

    it 'multiplies by 4 when a separator is present' do
      m = make_match(year: far_year, separator: '/')
      expect(host.date_guesses(m)).to eq 365 * 30 * 4
    end

    it 'applies a minimum year_space of MIN_YEAR_SPACE (20)' do
      m = make_match(year: current_year - 5, separator: '')
      expect(host.date_guesses(m)).to eq 365 * 20
    end
  end

  describe '#dictionary_guesses' do
    it 'returns rank for a plain lowercase word' do
      m = make_match(token: 'password', rank: 5, reversed: false, l33t: false)
      expect(host.dictionary_guesses(m)).to eq 5
    end

    it 'doubles guesses for a reversed match' do
      m = make_match(token: 'password', rank: 1, reversed: true, l33t: false)
      expect(host.dictionary_guesses(m)).to eq 2
    end

    it 'doubles guesses for a StartUpper token' do
      m = make_match(token: 'Password', rank: 1, reversed: false, l33t: false)
      expect(host.dictionary_guesses(m)).to eq 2
    end

    it 'applies all multipliers together (rank × reversed × l33t × uppercase)' do
      # token 'P4ss': rank=2, reversed=true (×2), l33t '4'→'a' all subbed (×2),
      # StartUpper capitalisation (×2) → 2 × 2 × 2 × 2 = 16
      m = make_match(token: 'P4ss', rank: 2, reversed: true, l33t: true, sub: { '4' => 'a' })
      expect(host.dictionary_guesses(m)).to eq 16
    end
  end

  describe '#uppercase_variations' do
    it 'returns 1 for all-lowercase tokens' do
      expect(host.uppercase_variations(make_match(token: 'password'))).to eq 1
    end

    it 'returns 2 for StartUpper' do
      expect(host.uppercase_variations(make_match(token: 'Password'))).to eq 2
    end

    it 'returns 2 for endUPPER' do
      expect(host.uppercase_variations(make_match(token: 'passworD'))).to eq 2
    end

    it 'returns 2 for ALL_UPPER' do
      expect(host.uppercase_variations(make_match(token: 'PASSWORD'))).to eq 2
    end

    it 'returns a combination count for mixed-case tokens' do
      # 'pAsSwOrD': 4 upper (A,S,O,D), 4 lower (p,s,w,r)
      # sum of nCk(8,i) for i=1..4 = 8 + 28 + 56 + 70 = 162
      expect(host.uppercase_variations(make_match(token: 'pAsSwOrD'))).to eq 162
    end
  end

  describe '#l33t_variations' do
    it 'returns 1 when the match has no l33t substitutions' do
      expect(host.l33t_variations(make_match(l33t: false))).to eq 1
    end

    it 'returns 1 when l33t is true but sub is nil' do
      expect(host.l33t_variations(make_match(l33t: true, sub: nil))).to eq 1
    end

    it 'returns 2 when all chars of a pair are substituted (no originals remain)' do
      # 'p4ssword': one '4', zero 'a' → doubles
      m = make_match(l33t: true, token: 'p4ssword', sub: { '4' => 'a' })
      expect(host.l33t_variations(m)).to eq 2
    end

    it 'uses combinations when both subbed and unsubbed chars are present' do
      # '4ppla4': two '4' substitutions, one original 'a' → nCk(3,1) = 3
      m = make_match(l33t: true, token: '4ppla4', sub: { '4' => 'a' })
      expect(host.l33t_variations(m)).to eq 3
    end

    it 'multiplies variation counts for each sub-pair independently' do
      # 'p4ss0ord': '4'→'a' all subbed (×2), '0'→'o' one subbed one original → nCk(2,1)=2 (×2)
      m = make_match(l33t: true, token: 'p4ss0ord', sub: { '4' => 'a', '0' => 'o' })
      expect(host.l33t_variations(m)).to eq 4
    end
  end

  describe '#estimate_guesses' do
    it 'returns a cached value when match.guesses is already set' do
      m = make_match(pattern: 'bruteforce', token: 'abc', guesses: 999)
      expect(host.estimate_guesses(m, 'abcdefgh')).to eq 999
    end

    it 'memoises the result on match.guesses' do
      m = make_match(pattern: 'bruteforce', token: 'abc')
      host.estimate_guesses(m, 'abc')
      expect(m.guesses).not_to be_nil
    end

    it 'applies a single-char minimum of 10 for sub-token single characters' do
      m = make_match(pattern: 'bruteforce', token: 'a')
      # bruteforce gives max(10,11)=11; token is a subtoken so floor is 10; result is 11
      expect(host.estimate_guesses(m, 'abc')).to eq 11
    end

    it 'applies a multi-char minimum of 50 for sub-token multi-character matches' do
      # dictionary rank=1 → guesses=1, but as a subtoken the floor is 50
      m = make_match(pattern: 'dictionary', token: 'pass', rank: 1, reversed: false, l33t: false)
      expect(host.estimate_guesses(m, 'password')).to eq 50
    end

    it 'applies no minimum when the token spans the full password' do
      m = make_match(pattern: 'dictionary', token: 'pass', rank: 1, reversed: false, l33t: false)
      expect(host.estimate_guesses(m, 'pass')).to eq 1
    end

    it 'dispatches to sequence_guesses for sequence pattern' do
      m = make_match(pattern: 'sequence', token: 'bcd', ascending: true)
      expect(host.estimate_guesses(m, 'bcd')).to eq 78
    end

    it 'dispatches to repeat_guesses for repeat pattern' do
      m = make_match(pattern: 'repeat', token: 'aaaa', base_guesses: 5, repeat_count: 4)
      expect(host.estimate_guesses(m, 'aaaa')).to eq 20
    end

    it 'dispatches to digits_guesses for digits pattern' do
      m = make_match(pattern: 'digits', token: '12345')
      expect(host.estimate_guesses(m, '12345')).to eq 100_000
    end

    it 'dispatches to year_guesses for year pattern' do
      year = Time.now.year - 30
      m = make_match(pattern: 'year', token: year.to_s)
      expect(host.estimate_guesses(m, year.to_s)).to eq 30
    end

    it 'dispatches to date_guesses for date pattern' do
      year = Time.now.year - 30
      m = make_match(pattern: 'date', token: '021297', year: year, separator: '')
      expect(host.estimate_guesses(m, '021297')).to eq 365 * 30
    end
  end
end
