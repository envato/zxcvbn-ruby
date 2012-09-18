module Zxcvbn
  module Matching
    # Given a password and a dictionary, match on any sequential segment of
    # the lowercased password in the dictionary

    class Dictionary
      def initialize(dictionary)
        @dictionary = dictionary
      end

      def matches(password)
        results = []
        password_length = password.length
        lowercased_password = password.downcase
        (0..password_length).each do |i|
          (i...password_length).each do |j|
            word = lowercased_password[i..j]
            if @dictionary.include?(word)
              results << Match.new(:matched_word => word)
            end
          end
        end
        results
      end
    end
  end
end