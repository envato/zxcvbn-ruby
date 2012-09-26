module Zxcvbn
  module Math
    def bruteforce_cardinality(password)
      is_type_of = {}

      password.each_byte do |ordinal|
        case ordinal
        when (48..57)
          is_type_of['digits'] = true
        when (65..90)
          is_type_of['upper'] = true
        when (97..122)
          is_type_of['lower'] = true
        else
          is_type_of['symbols'] = true
        end
      end

      cardinality = 0
      cardinality += 10 if is_type_of['digits']
      cardinality += 26 if is_type_of['upper']
      cardinality += 26 if is_type_of['lower']
      cardinality += 33 if is_type_of['symbols']
      cardinality
    end

    def display_time(seconds)
      minute  = 60
      hour    = minute * 60
      day     = hour * 24
      month   = day * 31
      year    = month * 12
      century = year * 100

      case
      when seconds < minute
        'instant'
      when seconds < hour
        "#{1 + (seconds / minute).ceil} minutes"
      when seconds < day
        "#{1 + (seconds / hour).ceil} hours"
      when seconds < month
        "#{1 + (seconds / day).ceil} days"
      when seconds < year
        "#{1 + (seconds / month).ceil} months"
      when seconds < century
        "#{1 + (seconds / year).ceil} years"
      else
        'centuries'
      end
    end

    def lg(n)
      ::Math.log(n, 2)
    end

    def nCk(n, k)
      return 0 if k > n
      return 1 if k == 0
      r = 1
      (1..k).each do |d|
        r = r * n
        r = r / d
        n -= 1
      end
      r
    end

    def min(a, b)
      a < b ? a : b
    end

    def average_degree_for_graph(graph_name)
      graph   = Zxcvbn::ADJACENCY_GRAPHS[graph_name]
      average = 0.0

      graph.each do |key, neighbors|
        average += neighbors.compact.length
      end

      average /= graph.keys.length
      average
    end

    def starting_positions_for_graph(graph_name)
      Zxcvbn::ADJACENCY_GRAPHS[graph_name].length
    end
  end
end