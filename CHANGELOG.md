# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

[Unreleased]: https://github.com/envato/zxcvbn-ruby/compare/v1.2.1...HEAD

## [1.2.1] - 2025-12-05

### Removed
- Removed the dependency on the Ruby `benchmark` module ([#44]).
- Tests are no longer included in the gem package ([#45]).

[1.2.1]: https://github.com/envato/zxcvbn-ruby/compare/v1.2.0...v.1.2.1
[#44]: https://github.com/envato/zxcvbn-ruby/pull/44
[#45]: https://github.com/envato/zxcvbn-ruby/pull/45

## [1.2.0] - 2021-01-05

### Added
 - Support for Ruby 3 (thanks [@RSO] ([#32]))

### Changed
 - Use [mini\_racer] for running JavaScript specs (thanks [@RSO] ([#33]))
 - Moved CI to GitHub Actions ([#34])

[1.2.0]: https://github.com/envato/zxcvbn-ruby/compare/v1.1.0...v.1.2.0
[@rso]: https://github.com/RSO
[mini\_racer]: https://rubygems.org/gems/mini_racer/
[#32]: https://github.com/envato/zxcvbn-ruby/pull/32
[#33]: https://github.com/envato/zxcvbn-ruby/pull/33
[#34]: https://github.com/envato/zxcvbn-ruby/pull/34

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
[#28]: https://github.com/envato/zxcvbn-ruby/pull/28
[#29]: https://github.com/envato/zxcvbn-ruby/pull/29

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
