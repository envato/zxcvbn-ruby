# frozen_string_literal: true

module Zxcvbn
  # Mathematical utilities used by the guess estimation logic.
  # @api private
  module Math
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
