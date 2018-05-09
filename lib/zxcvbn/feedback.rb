module Zxcvbn
  class Feedback
    attr_accessor :warning, :suggestions

    def initialize(options = {})
      @warning     = options[:warning]
      @suggestions = options[:suggestions] || []
    end
  end
end
