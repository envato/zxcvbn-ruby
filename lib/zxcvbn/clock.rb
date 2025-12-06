# frozen_string_literal: true

module Zxcvbn
  module Clock
    def self.realtime
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
      Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
    end
  end
end
