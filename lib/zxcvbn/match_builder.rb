# frozen_string_literal: true

require 'zxcvbn/match'

module Zxcvbn
  # Mutable accumulator for match attributes. Matchers populate a builder
  # incrementally; {#build} seals it into an immutable {Match}.
  # @api private
  MatchBuilder = Struct.new(*Match.members, keyword_init: true) do
    # @return [Match] immutable match with the current attribute values
    def build
      Match.new(**to_h.tap { |h| h[:sub]&.freeze })
    end
  end
end
