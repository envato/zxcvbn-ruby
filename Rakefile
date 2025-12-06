# frozen_string_literal: true

require "bundler/gem_tasks"
require "bundler/setup"
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new('spec')
RuboCop::RakeTask.new('rubocop')

task default: %i[spec rubocop]

task :console do
  require 'zxcvbn'
  require './spec/support/js_helpers'
  include JsHelpers
  require 'irb'
  ARGV.clear
  IRB.start
  1
end

task :compile_coffeescript do
  system('coffee --compile --bare spec/support/js_source/{matching,scoring,init}.coffee', exception: true)
  system(<<~COMMAND.strip, exception: true)
    cat spec/support/js_source/{matching,scoring,adjacency_graphs,frequency_lists,init}.js > spec/support/js_source/compiled.js
  COMMAND
end
