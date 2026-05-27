# frozen_string_literal: true

require 'mini_racer'

module JsHelpers
  class JsMethodInvoker
    JS_SOURCE_PATH = Pathname(File.expand_path('js_source', __dir__))

    def initialize
      @ctx = MiniRacer::Context.new
      @ctx.eval(JS_SOURCE_PATH.join('zxcvbn_v4.4.2.js').read)
    end

    def js_eval(string)
      @ctx.eval(string)
    end

    def eval_convert_object(javascript)
      js_eval(javascript)
    end
  end

  def method_invoker
    $method_invoker ||= JsMethodInvoker.new
  end

  def run_js(javascript)
    method_invoker.eval_convert_object(javascript)
  end

  def js_zxcvbn(password)
    run_js("zxcvbn(#{password.to_json})")
  end
end
