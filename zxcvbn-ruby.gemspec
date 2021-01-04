# -*- encoding: utf-8 -*-
require File.expand_path('../lib/zxcvbn/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Steve Hodgkiss", "Matthieu Aussaguel"]
  gem.email         = ["steve@hodgkiss.me", "matthieu.aussaguel@gmail.com"]
  gem.description   = %q{Ruby port of Dropboxs zxcvbn.js}
  gem.summary       = %q{}
  gem.homepage      = "http://github.com/envato/zxcvbn-ruby"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "zxcvbn-ruby"
  gem.require_paths = ["lib"]
  gem.version       = Zxcvbn::VERSION
  gem.license       = 'MIT'

  gem.required_ruby_version = '>= 2.5'

  gem.add_development_dependency 'mini_racer'
  gem.add_development_dependency 'rspec'

  gem.metadata = {
    "bug_tracker_uri" => "https://github.com/envato/zxcvbn-ruby/issues",
    "changelog_uri" => "https://github.com/envato/zxcvbn-ruby/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://github.com/envato/zxcvbn-ruby/blob/master/README.md",
    "homepage_uri" => "https://github.com/envato/zxcvbn-ruby",
    "source_code_uri" => "https://github.com/envato/zxcvbn-ruby"
  }
end
