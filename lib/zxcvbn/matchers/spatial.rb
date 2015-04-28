require 'zxcvbn/match'

module Zxcvbn
  module Matchers
    class Spatial
      def initialize(graphs)
        @graphs = graphs
      end

      def matches(password)
        results = []
        @graphs.each do |graph_name, graph|
          results += matches_for_graph(graph, graph_name, password)
        end
        results
      end

      def matches_for_graph(graph, graph_name, password)
        result = []
        i = 0
        while i < password.length - 1
          j = i + 1
          last_direction = nil
          turns = 0
          shifted_count = 0
          loop do
            prev_char = password[j-1]
            found = false
            found_direction = -1
            cur_direction = -1
            adjacents = graph[prev_char] || []
            # consider growing pattern by one character if j hasn't gone over the edge.
            if j < password.length
              cur_char = password[j]
              adjacents.each do |adj|
                cur_direction += 1
                if adj && adj.index(cur_char)
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
            end
            # if the current pattern continued, extend j and try to grow again
            if found
              j += 1
            else
              # otherwise push the pattern discovered so far, if any...
              if j - i > 2 # don't consider length 1 or 2 chains.
                result << Match.new(
                  :pattern => 'spatial',
                  :i => i,
                  :j => j-1,
                  :token => password[i...j],
                  :graph => graph_name,
                  :turns => turns,
                  :shifted_count => shifted_count
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