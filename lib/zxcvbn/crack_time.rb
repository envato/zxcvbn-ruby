module Zxcvbn::CrackTime
  SINGLE_GUESS = 0.010
  NUM_ATTACKERS = 100

  SECONDS_PER_GUESS = SINGLE_GUESS / NUM_ATTACKERS

  def entropy_to_crack_time(entropy)
    0.5 * (2 ** entropy) * SECONDS_PER_GUESS
  end

  def crack_time_to_score(seconds)
    case
    when seconds < 10**2
      0
    when seconds < 10**4
      1
    when seconds < 10**6
      2
    when seconds < 10**8
      3
    else
      4
    end
  end
end