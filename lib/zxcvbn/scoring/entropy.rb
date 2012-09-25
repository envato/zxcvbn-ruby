module Zxcvbn::Scoring::Entropy
  include Zxcvbn::Scoring::Math

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
  ALL_UPPER   = /^[^a-z]+$/
  ALL_LOWER   = /^[^A-Z]+$/

  def extra_uppercase_entropy(match)
    word = match.token
    [START_UPPER, END_UPPER, ALL_UPPER].each do |regex|
      return 1 if word.match(regex)
    end
    num_upper = word.chars.count{|c| c.match(/[A-Z]/) }
    num_lower = word.chars.count{|c| c.match(/[a-z]/) }
    possibilities = 0
    (0..min(num_upper, num_lower)).each do |i|
      possibilities += nCk(num_upper + num_lower, i)
    end
    lg(possibilities)
  end

  def extra_l33t_entropy(match)
    word = match.token
    return 0 unless match.l33t
    possibilities = 0
      debugger
    match.sub.each do |subbed, unsubbed|
      num_subbed = word.chars.count{|c| c == subbed}
      num_unsubbed = word.chars.count{|c| c == unsubbed}
      (0..min(num_subbed, num_unsubbed)).each do |i|
        possibilities += nCk(num_subbed + num_unsubbed, i)
      end
    end
    lg(possibilities) || 1
  end
end