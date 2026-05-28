# frozen_string_literal: true

require File.expand_path('lib/zxcvbn/version', __dir__)

Gem::Specification.new do |gem|
  gem.name        = 'zxcvbn-ruby'
  gem.version     = Zxcvbn::VERSION
  gem.description = 'Ruby port of Dropboxs zxcvbn.js'
  gem.summary     = ''
  gem.authors     = ['Steve Hodgkiss', 'Matthieu Aussaguel']
  gem.email       = ['steve@hodgkiss.me', 'matthieu.aussaguel@gmail.com']
  gem.homepage    = "https://github.com/envato/#{gem.name}"
  gem.license     = 'MIT'

  gem.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri' => "#{gem.homepage}/issues",
    'changelog_uri' => "#{gem.homepage}/blob/HEAD/CHANGELOG.md",
    'documentation_uri' => "https://www.rubydoc.info/gems/#{gem.name}/#{gem.version}",
    'homepage_uri' => gem.homepage,
    'source_code_uri' => "#{gem.homepage}/tree/v#{gem.version}",
    'rubygems_mfa_required' => 'true'
  }

  gem.required_ruby_version = '>= 3.3'

  gem.require_paths = ['lib']

  gem.files = `git ls-files -z`.split("\x0").reject do |file|
    file.match(%r{^(\.|CODE_OF_CONDUCT.md|Gemfile|Rakefile|Guardfile|zxcvbn-ruby.gemspec|rbs_collection.yaml|spec/)})
  end
end
