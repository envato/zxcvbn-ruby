# frozen_string_literal: true

require 'zxcvbn/match'

module Zxcvbn
  module Matchers
    # Matches keyboard spatial patterns (e.g. "qwerty", "asdf") across all
    # configured adjacency graphs.
    class Spatial
      # Matches characters that require the Shift key on a standard keyboard.
      SHIFTED_RX = /[~!@#$%^&*()_+QWERTYUIOP{}|ASDFGHJKL:"ZXCVBNM<>?]/

      # @param graphs [Hash{String => Hash}] adjacency graph data keyed by graph name
      def initialize(graphs)
        @graphs = graphs
      end

      # @param password [String]
      # @return [Array<Match>] matches with pattern "spatial" across all graphs
      def matches(password)
        results = []
        @graphs.each do |graph_name, graph|
          results += matches_for_graph(graph, graph_name, password)
        end
        results
      end

      # Returns spatial matches found in password using a single adjacency graph.
      #
      # @param graph [Hash] adjacency map for each key character
      # @param graph_name [String] name of the graph (e.g. "qwerty")
      # @param password [String]
      # @return [Array<Match>] matches with pattern "spatial"
      def matches_for_graph(graph, graph_name, password)
        result = []
        keyboard_graph = %w[qwerty dvorak].include?(graph_name)
        i = 0
        while i < password.length - 1
          j = i + 1
          last_direction = nil
          turns = 0
          shifted_count = keyboard_graph && SHIFTED_RX.match?(password[i]) ? 1 : 0
          loop do
            prev_char = password[j - 1]
            found = false
            found_direction = -1
            cur_direction = -1
            adjacents = graph[prev_char] || []
            # consider growing pattern by one character if j hasn't gone over the edge.
            if j < password.length
              cur_char = password[j]
              adjacents.each do |adj|
                cur_direction += 1
                next unless adj&.index(cur_char)

                found = true
                found_direction = cur_direction
                if adj.index(cur_char) == 1
                  # index 1 in the adjacency means the key is shifted, 0 means unshifted: A vs a, % vs 5, etc.
                  # for example, 'q' is adjacent to the entry '2@'. @ is shifted w/ index 1, 2 is unshifted.
                  shifted_count += 1
                end
                if last_direction != found_direction
                  # adding a turn is correct even in the initial case when last_direction is null:
                  # every spatial pattern starts with a turn.
                  turns += 1
                  last_direction = found_direction
                end
                break
              end
            end
            # if the current pattern continued, extend j and try to grow again
            if found
              j += 1
            else
              # otherwise push the pattern discovered so far, if any...
              if j - i > 2 # don't consider length 1 or 2 chains.
                result << Match.new(
                  pattern: 'spatial',
                  i:,
                  j: j - 1,
                  token: password.slice(i, j - i),
                  graph: graph_name,
                  turns:,
                  shifted_count:
                )
              end
              # ...and then start a new search for the rest of the password.
              i = j
              break
            end
          end
        end
        result
      end
    end
  end
end
