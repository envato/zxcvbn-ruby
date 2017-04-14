require 'zxcvbn/math'

module Zxcvbn::Entropy
  include Zxcvbn::Math

  def calc_entropy(match)
    return match.entropy unless match.entropy.nil?

    match.entropy = case match.pattern
                    when 'repeat'
                      repeat_entropy(match)
                    when 'sequence'
                      sequence_entropy(match)
                    when 'digits'
                      digits_entropy(match)
                    when 'year'
                      year_entropy(match)
                    when 'date'
                      date_entropy(match)
                    when 'spatial'
                      spatial_entropy(match)
                    when 'dictionary'
                      dictionary_entropy(match)
                    else
                      0
                    end
  end

  def repeat_entropy(match)
    cardinality = bruteforce_cardinality match.token
    lg(cardinality * match.token.length)
  end

  def sequence_entropy(match)
    first_char = match.token[0]
    base_entropy = if ['a', '1'].include?(first_char)
      1
    elsif first_char.match(/\d/)
      lg(10)
    elsif first_char.match(/[a-z]/)
      lg(26)
    else
      lg(26) + 1
    end
    base_entropy += 1 unless match.ascending
    base_entropy + lg(match.token.length)
  end

  def digits_entropy(match)
    lg(10 ** match.token.length)
  end

  NUM_YEARS = 119 # years match against 1900 - 2019
  NUM_MONTHS = 12
  NUM_DAYS = 31

  def year_entropy(match)
    lg(NUM_YEARS)
  end

  def date_entropy(match)
    if match.year < 100
      entropy = lg(NUM_DAYS * NUM_MONTHS * 100)
    else
      entropy = lg(NUM_DAYS * NUM_MONTHS * NUM_YEARS)
    end

    if match.separator
      entropy += 2
    end

    entropy
  end

  def dictionary_entropy(match)
    match.base_entropy = lg(match.rank)
    match.uppercase_entropy = extra_uppercase_entropy(match)
    match.l33t_entropy = extra_l33t_entropy(match)

    match.base_entropy + match.uppercase_entropy + match.l33t_entropy
  end

  START_UPPER = /^[A-Z][^A-Z]+$/
  END_UPPER   = /^[^A-Z]+[A-Z]$/
  ALL_UPPER   = /^[A-Z]+$/
  ALL_LOWER   = /^[a-z]+$/

  def extra_uppercase_entropy(match)
    word = match.token
    [START_UPPER, END_UPPER, ALL_UPPER].each do |regex|
      return 1 if word.match(regex)
    end
    num_upper = word.chars.count{|c| c.match(/[A-Z]/) }
    num_lower = word.chars.count{|c| c.match(/[a-z]/) }
    possibilities = 0
    (0..[num_upper, num_lower].min).each do |i|
      possibilities += nCk(num_upper + num_lower, i)
    end
    lg(possibilities)
  end

  def extra_l33t_entropy(match)
    word = match.token
    return 0 unless match.l33t
    possibilities = 0
    match.sub.each do |subbed, unsubbed|
      num_subbed = word.chars.count{|c| c == subbed}
      num_unsubbed = word.chars.count{|c| c == unsubbed}
      (0..[num_subbed, num_unsubbed].min).each do |i|
        possibilities += nCk(num_subbed + num_unsubbed, i)
      end
    end
    entropy = lg(possibilities)
    entropy == 0 ? 1 : entropy
  end

  def spatial_entropy(match)
    if %w|qwerty dvorak|.include? match.graph
      starting_positions = starting_positions_for_graph('qwerty')
      average_degree     = average_degree_for_graph('qwerty')
    else
      starting_positions = starting_positions_for_graph('keypad')
      average_degree     = average_degree_for_graph('keypad')
    end

    possibilities = 0
    token_length  = match.token.length
    turns         = match.turns

    # estimate the ngpumber of possible patterns w/ token length or less with number of turns or less.
    (2..token_length).each do |i|
      possible_turns = [turns, i - 1].min
      (1..possible_turns).each do |j|
        possibilities += nCk(i - 1, j - 1) * starting_positions * average_degree ** j
      end
    end

    entropy = lg possibilities
    # add extra entropy for shifted keys. (% instead of 5, A instead of a.)
    # math is similar to extra entropy from uppercase letters in dictionary matches.

    if match.shifted_count
      shiffted_count  = match.shifted_count
      unshifted_count = match.token.length - match.shifted_count
      possibilities   = 0

      (0..[shiffted_count, unshifted_count].min).each do |i|
        possibilities += nCk(shiffted_count + unshifted_count, i)
      end
      entropy += lg possibilities
    end
    entropy
  end
end
