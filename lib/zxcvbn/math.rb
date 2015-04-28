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

    def average_degree_for_graph(graph_name)
      graph = data.adjacency_graphs[graph_name]
      degrees = graph.map { |_, neighbors| neighbors.compact.size }
      sum = degrees.inject(0, :+)
      sum.to_f / graph.size
    end

    def starting_positions_for_graph(graph_name)
      data.adjacency_graphs[graph_name].length
    end
  end
end
