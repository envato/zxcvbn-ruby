# frozen_string_literal: true

require 'zxcvbn/data'
require 'zxcvbn/tester'

module Zxcvbn
  # Fluent builder for constructing a {Tester} with custom word lists and options.
  #
  # Obtain a builder via {Zxcvbn.tester_builder} and call {#build} to get the {Tester}.
  #
  # Example:
  #
  #   tester = Zxcvbn
  #     .tester_builder
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
    # @param words [Array<String>] words to add; non-String elements are silently ignored during matching
    # @return [self]
    # @raise [ArgumentError] if words is not an Array
    def add_word_list(name, words)
      raise ArgumentError, "words must be an Array; got #{words.inspect}" unless words.is_a?(Array)

      @word_lists[name] = words
      self
    end

    # @param length [Integer] maximum password length for the built {Tester}
    # @return [self]
    # @raise [ArgumentError] if length is not a positive integer
    def max_password_length(length)
      unless length.is_a?(Integer) && length.positive?
        raise ArgumentError, "max_password_length must be a positive integer; got #{length.inspect}"
      end

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

      env_str = ENV['ZXCVBN_MAX_PASSWORD_LENGTH']
      return DEFAULT_MAX_PASSWORD_LENGTH unless env_str

      value = begin
        Integer(env_str, 10)
      rescue ArgumentError
        raise ArgumentError, "ZXCVBN_MAX_PASSWORD_LENGTH must be a positive integer; got #{env_str.inspect}"
      end

      unless value.positive?
        raise ArgumentError, "ZXCVBN_MAX_PASSWORD_LENGTH must be a positive integer; got #{env_str.inspect}"
      end

      value
    end
  end
end
