#!/usr/bin/env rake
require "bundler/gem_tasks"
require "bundler/setup"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')
task default: [:spec]

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
  `coffee --compile --bare spec/support/js_source/{matching,scoring,init}.coffee`
  `cat spec/support/js_source/{matching,scoring,adjacency_graphs,frequency_lists,init}.js > spec/support/js_source/compiled.js`
end
