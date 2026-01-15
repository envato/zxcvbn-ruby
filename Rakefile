# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new('spec')
RuboCop::RakeTask.new('rubocop')

begin
  require 'rbs/cli'

  namespace :rbs do
    desc 'Validate RBS type signatures'
    task :validate do
      sh 'rbs -I sig validate'
    end

    desc 'Run RBS runtime type checker with RSpec'
    task :test do
      sh "rbs -I sig test --target 'Zxcvbn::*' rspec"
    end

    desc 'List RBS types'
    task :list do
      sh 'rbs -I sig list | grep Zxcvbn'
    end

    desc 'Check RBS syntax'
    task :parse do
      sh 'rbs -I sig parse sig/**/*.rbs'
    end
  end
rescue LoadError
  # RBS is not available
end

task default: %i[spec rubocop rbs:validate]

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
