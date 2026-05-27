# frozen_string_literal: true

require 'zxcvbn/data'
require 'zxcvbn/tester'

module Zxcvbn
  # Fluent builder for constructing a {Tester} with custom word lists and options.
  #
  # Obtain a builder via {Zxcvbn.tester} and call {#build} to get the {Tester}.
  #
  # Example:
  #
  #   tester = Zxcvbn.tester
  #     .add_word_list('company', %w[acme corp])
  #     .max_password_length(75)
  #     .build
  class TesterBuilder
    # Default maximum password length used when neither {#max_password_length} nor
    # the +ZXCVBN_MAX_PASSWORD_LENGTH+ environment variable is set.
    DEFAULT_MAX_PASSWORD_LENGTH = 256

    def initialize
      @word_lists = {}
      @max_password_length = nil
    end

    # @param name [String] identifier for the word list; calling with the same name twice replaces the earlier list
    # @param words [Array<String>] words to add
    # @return [self]
    def add_word_list(name, words)
      @word_lists[name] = words
      self
    end

    # @param length [Integer] maximum password length for the built {Tester}
    # @return [self]
    def max_password_length(length)
      @max_password_length = length
      self
    end

    # @return [Tester]
    # @raise [ArgumentError] if max_password_length or ZXCVBN_MAX_PASSWORD_LENGTH is not a positive integer
    def build
      data = Data.new
      @word_lists.each_pair { |name, words| data.add_word_list(name, words) }
      Tester.new(data: data.freeze, max_password_length: effective_max_password_length).freeze
    end

    private

    def effective_max_password_length
      return @max_password_length if @max_password_length

      value = begin
        Integer(ENV.fetch('ZXCVBN_MAX_PASSWORD_LENGTH', DEFAULT_MAX_PASSWORD_LENGTH))
      rescue ArgumentError, TypeError
        raise ArgumentError,
              'ZXCVBN_MAX_PASSWORD_LENGTH must be a positive integer; ' \
              "got #{ENV['ZXCVBN_MAX_PASSWORD_LENGTH'].inspect}"
      end

      unless value.positive?
        raise ArgumentError,
              'ZXCVBN_MAX_PASSWORD_LENGTH must be a positive integer; ' \
              "got #{ENV['ZXCVBN_MAX_PASSWORD_LENGTH'].inspect}"
      end

      value
    end
  end
end
