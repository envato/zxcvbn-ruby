module Zxcvbn
  require "execjs"

  class Tester
    def initialize
      src = File.open("./data/zxcvbn.js", 'r').read
      @context = ExecJS.compile(src)
    end

    def test(password, user_inputs = [])
      result = @context.eval("zxcvbn(#{password.to_json}, #{user_inputs.to_json})")
      OpenStruct.new(result)
    end
  end
end
