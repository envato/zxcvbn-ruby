module Zxcvbn::Scoring::Entropy
  include Zxcvbn::Scoring::Math

  def digits_entropy(match)
    lg(10 ** match.token.length)
  end
end