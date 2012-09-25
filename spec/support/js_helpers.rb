require 'v8'

module JsHelpers
  class JsMethodInvoker
    JS_SOURCE_PATH = Pathname(File.expand_path('../js_source/', __FILE__))

    def initialize
      @ctx = V8::Context.new do |ctx|
        ctx.eval(JS_SOURCE_PATH.join('compiled.js').read)
      end
    end

    def eval(string)
      @ctx.eval(string)
    end

    def eval_convert_object(string)
      serialized = eval("JSON.stringify(#{string})")
      JSON.parse(serialized)
    end
  end

  def method_invoker
    $method_invoker ||= JsMethodInvoker.new
  end

  def js_zxcvbn(password)
    method_invoker.eval_convert_object("zxcvbn('#{password}')")
  end
end