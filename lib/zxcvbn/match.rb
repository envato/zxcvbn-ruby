require 'ostruct'

module Zxcvbn
  class Match < OpenStruct
    def to_hash
      hash = @table.dup
      hash.keys.sort.each do |key|
        hash[key.to_s] = hash.delete(key)
      end
      hash
    end
  end
end