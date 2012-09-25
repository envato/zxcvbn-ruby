module Zxcvbn::Scoring::Entropy
  include Zxcvbn::Scoring::Math

  def digits_entropy(match)
    lg(10 ** match.token.length)
  end

  NUM_YEARS = 119 # years match against 1900 - 2019
  NUM_MONTHS = 12
  NUM_DAYS = 31

  def year_entropy(match)
    lg NUM_YEARS
  end
end