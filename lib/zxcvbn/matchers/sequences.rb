# frozen_string_literal: true

require 'zxcvbn/match'

module Zxcvbn
  module Matchers
    class Sequences
      MAX_DELTA  = 5
      ALL_LOWER  = /^[a-z]+$/.freeze
      ALL_UPPER  = /^[A-Z]+$/.freeze
      ALL_DIGITS = /^\d+$/.freeze

      def matches(password)
        return [] if password.length == 1

        result = []
        start = 0
        last_delta = nil

        emit = lambda do |seq_end, delta|
          return if delta.nil?

          abs_delta = delta.abs
          return unless abs_delta.positive? && abs_delta <= MAX_DELTA

          len = seq_end - start + 1
          return unless len > 2 || abs_delta == 1

          token = password[start, len]
          seq_name, seq_space = classify(token)
          result << Match.new(
            pattern: 'sequence',
            i: start,
            j: seq_end,
            token: token,
            sequence_name: seq_name,
            sequence_space: seq_space,
            ascending: delta.positive?
          )
        end

        (1...password.length).each do |i|
          delta = password[i].ord - password[i - 1].ord
          last_delta = delta if last_delta.nil?
          next if delta == last_delta

          emit.call(i - 1, last_delta)
          start = i - 1
          last_delta = delta
        end
        emit.call(password.length - 1, last_delta)

        result
      end

      private

      def classify(token)
        case token
        when ALL_LOWER  then ['lower', 26]
        when ALL_UPPER  then ['upper', 26]
        when ALL_DIGITS then ['digits', 10]
        else                 ['unicode', 26]
        end
      end
    end
  end
end
