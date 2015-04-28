require 'zxcvbn/data'
require 'zxcvbn/password_strength'

module Zxcvbn
  # Allows you to test the strength of multiple passwords without reading and
  # parsing the dictionary data from disk each test. Dictionary data is read
  # once from disk and stored in memory for the life of the Tester object.
  #
  # Example:
  #
  #   tester = Zxcvbn::Tester.new
  #
  #   tester.add_word_lists("custom" => ["words"])
  #
  #   tester.test("password 1")
  #   tester.test("password 2")
  #   tester.test("password 3")
  class Tester
    def initialize
      @data = Data.new
    end

    def test(password, user_inputs = [])
      PasswordStrength.new(@data).test(password, user_inputs)
    end

    def add_word_lists(lists)
      lists.each_pair {|name, words| @data.add_word_list(name, words)}
    end

    def inspect
      "#<#{self.class}:0x#{self.__id__.to_s(16)}>"
    end
  end
end
