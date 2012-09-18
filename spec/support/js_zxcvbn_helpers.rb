require 'v8'

module JsZxcvbnHelpers
  class PasswordStrength
    ZXCVBN_SOURCE = File.read(File.expand_path('../zxcvbn.js', __FILE__))
    ATTRIBUTES = %w[ entropy crack_time crack_time_display score calc_time ]

    def initialize
      @ctx = V8::Context.new do |ctx|
        ctx.eval('exports = {}')
        ctx.eval(ZXCVBN_SOURCE)
      end
    end

    def zxcvbn(password)
      @ctx.eval("result = exports.zxcvbn('#{password}')")
      results = ATTRIBUTES.inject({}) do |hash, attribute|
        hash[attribute] = @ctx.eval("result.#{attribute}")
        hash
      end
      @ctx.eval("delete result")
      results
    end
  end

  def js_zxcvbn(password)
    $password_strength ||= PasswordStrength.new
    $password_strength.zxcvbn(password)
  end
end