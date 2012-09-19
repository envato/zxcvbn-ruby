require 'bundler/setup'
require 'rspec'
require 'zxcvbn'

Dir[Pathname.new(File.expand_path('../', __FILE__)).join('support/**/*.rb')].each {|f| require f}

Zxcvbn.build_ranked_dictionaries

RSpec.configure do |config|
  config.include JsZxcvbnHelpers
end