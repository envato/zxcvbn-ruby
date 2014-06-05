require 'ostruct'

module Zxcvbn
  class Match < OpenStruct
    def to_hash
      @table.keys.sort.each_with_object({}) do |key, hash|
        hash[key.to_s] = @table[key]
      end
    end
  end
end
