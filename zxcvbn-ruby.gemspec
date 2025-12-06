# frozen_string_literal: true

require File.expand_path('../lib/zxcvbn/version', __FILE__)

GITHUB_URL = 'https://github.com/envato/zxcvbn-ruby'

Gem::Specification.new do |gem|
  gem.authors       = ["Steve Hodgkiss", "Matthieu Aussaguel"]
  gem.email         = ["steve@hodgkiss.me", "matthieu.aussaguel@gmail.com"]
  gem.description   = %q{Ruby port of Dropboxs zxcvbn.js}
  gem.summary       = %q{}
  gem.homepage      = "http://github.com/envato/zxcvbn-ruby"

  gem.files         = `git ls-files -z`.split("\x0").reject do |file|
    file.match(%r{^(\.|CODE_OF_CONDUCT.md|Gemfile|Rakefile|Guardfile|zxcvbn-ruby.gemspec|spec/)})
  end
  gem.name          = "zxcvbn-ruby"
  gem.require_paths = ["lib"]
  gem.version       = Zxcvbn::VERSION
  gem.license       = 'MIT'

  gem.required_ruby_version = '>= 2.5'

  gem.metadata = {
    'bug_tracker_uri' => "#{GITHUB_URL}/issues",
    'changelog_uri' => "#{GITHUB_URL}/blob/HEAD/CHANGELOG.md",
    'documentation_uri' => "#{GITHUB_URL}/blob/HEAD/README.md",
    'homepage_uri' => GITHUB_URL,
    'source_code_uri' => GITHUB_URL
  }
end
