# frozen_string_literal: true

module Zxcvbn
  # Mathematical utilities used by the guess estimation logic.
  module Math
    # Estimates the brute-force cardinality of the character set used in password.
    #
    # @param password [String] the password being evaluated
    # @return [Integer] size of the character space (digits + upper + lower + symbols)
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

    # Computes log base 2 of n.
    #
    # @param n [Numeric]
    # @return [Float]
    def lg(n)
      ::Math.log(n, 2)
    end

    # Computes the binomial coefficient C(n, k) ("n choose k").
    #
    # @param n [Integer]
    # @param k [Integer]
    # @return [Integer]
    def nCk(n, k)
      return 0 if k > n
      return 1 if k.zero?

      # Use symmetry property: C(n,k) = C(n, n-k)
      # Choose smaller k to minimize iterations
      k = n - k if k > n - k

      r = 1
      (1..k).each do |d|
        r *= n
        r /= d
        n -= 1
      end
      r
    end

    # Returns the precomputed average key-adjacency degree for a keyboard graph.
    #
    # @param graph_name [String] e.g. "qwerty" or "keypad"
    # @return [Float]
    def average_degree_for_graph(graph_name)
      data.graph_stats[graph_name][:average_degree]
    end

    # Returns the number of starting positions (keys) in a keyboard graph.
    #
    # @param graph_name [String] e.g. "qwerty" or "keypad"
    # @return [Integer]
    def starting_positions_for_graph(graph_name)
      data.graph_stats[graph_name][:starting_positions]
    end
  end
end
