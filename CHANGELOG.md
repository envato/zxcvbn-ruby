# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

[Unreleased]: https://github.com/envato/zxcvbn-ruby/compare/v1.1.0...HEAD

## [1.1.0] - 2020-07-16
### Added
 - Support for Ruby 2.7 ([#29])
 - Gem metadata ([#29])

### Removed
 - Support for Ruby 2.3 ([#29])
 - Support for Ruby 2.4 ([#29])

### Fixed
 - Invalid user dictionaries are handled more robustly ([#28])

[1.1.0]: https://github.com/envato/zxcvbn-ruby/compare/v1.0.0...v1.1.0
[28]: https://github.com/envato/zxcvbn-ruby/pull/28
[29]: https://github.com/envato/zxcvbn-ruby/pull/29

## [1.0.0] - 2019-05-14
### Added
 - License info in the gemspec ([#21])
 - More ported password checking features to bring this gem more up to date. ([#22])
    - spatial - Keyboard patterns
    - repeat - Repeated characters
    - sequence - easily guessable sequences
    - date - date associations

### Removed
- This gem will no longer run on Ruby versions < 2.3 ([#25])

[1.0.0]: https://github.com/envato/zxcvbn-ruby/compare/v0.1.2...v1.0.0
[#21]: https://github.com/envato/zxcvbn-ruby/pull/21
[#22]: https://github.com/envato/zxcvbn-ruby/pull/22
[#25]: https://github.com/envato/zxcvbn-ruby/pull/25
