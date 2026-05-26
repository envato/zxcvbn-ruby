# frozen_string_literal: true

module Zxcvbn
  # Monotonic-clock utility for measuring elapsed time.
  # @api private
  module Clock
    # Yields to the block and returns the elapsed time in seconds.
    #
    # @yield block whose execution time is measured
    # @return [Float] elapsed seconds as a monotonic-clock duration
    def self.realtime
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
      Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
    end
  end
end
