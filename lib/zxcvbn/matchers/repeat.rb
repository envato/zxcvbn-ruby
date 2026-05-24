# frozen_string_literal: true

require 'zxcvbn/match'

module Zxcvbn
  module Matchers
    class Repeat
      GREEDY        = /(.+)\1+/.freeze
      LAZY          = /(.+?)\1+/.freeze
      LAZY_ANCHORED = /^(.+?)\1+$/.freeze

      def matches(password)
        result = []
        last_index = 0

        while last_index < password.length
          greedy_match = GREEDY.match(password, last_index)
          lazy_match   = LAZY.match(password, last_index)
          break unless greedy_match

          if greedy_match[0].length > lazy_match[0].length
            rx_match   = greedy_match
            base_token = LAZY_ANCHORED.match(rx_match[0])[1]
          else
            rx_match   = lazy_match
            base_token = rx_match[1]
          end

          i     = rx_match.begin(0)
          j     = rx_match.end(0) - 1
          token = rx_match[0]

          result << Match.new(
            pattern: 'repeat',
            i: i,
            j: j,
            token: token,
            base_token: base_token,
            repeat_count: token.length / base_token.length
          )

          last_index = j + 1
        end

        result
      end
    end
  end
end
