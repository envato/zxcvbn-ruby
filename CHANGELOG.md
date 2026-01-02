# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
 - Replace OpenStruct with regular class in `Zxcvbn::Match` for 2x performance improvement ([#61])
 - Implement Trie data structure for dictionary matching with 1.4x additional performance improvement ([#62])
 - Replace range operators with `String#slice` for string slicing operations ([#63])
 - Optimise L33t matcher with early bailout and improved deduplication ([#64])

[Unreleased]: https://github.com/envato/zxcvbn-ruby/compare/v1.2.4...HEAD
[#61]: https://github.com/envato/zxcvbn-ruby/pull/61
[#62]: https://github.com/envato/zxcvbn-ruby/pull/62
[#63]: https://github.com/envato/zxcvbn-ruby/pull/63
[#64]: https://github.com/envato/zxcvbn-ruby/pull/64

## [1.2.4] - 2025-12-07

### Changed
 - Address security issues found by RuboCop ([#57])

[1.2.4]: https://github.com/envato/zxcvbn-ruby/compare/v1.2.3...v1.2.4
[#57]: https://github.com/envato/zxcvbn-ruby/pull/57

## [1.2.3] - 2025-12-07

### Changed
 - Address linting issues found by RuboCop ([#52])
 - Address style issues found by RuboCop ([#53], [#54], [#55])

[1.2.3]: https://github.com/envato/zxcvbn-ruby/compare/v1.2.2...v1.2.3
[#52]: https://github.com/envato/zxcvbn-ruby/pull/52
[#53]: https://github.com/envato/zxcvbn-ruby/pull/53
[#54]: https://github.com/envato/zxcvbn-ruby/pull/54
[#55]: https://github.com/envato/zxcvbn-ruby/pull/55

## [1.2.2] - 2025-12-06

### Changed
 - Address layout and frozen string literal issues ([#49])

[1.2.2]: https://github.com/envato/zxcvbn-ruby/compare/v1.2.1...v1.2.2
[#49]: https://github.com/envato/zxcvbn-ruby/pull/49

## [1.2.1] - 2025-12-05

### Removed
- Removed the dependency on the Ruby `benchmark` module ([#44]).
- Tests are no longer included in the gem package ([#45]).

[1.2.1]: https://github.com/envato/zxcvbn-ruby/compare/v1.2.0...v1.2.1
[#44]: https://github.com/envato/zxcvbn-ruby/pull/44
[#45]: https://github.com/envato/zxcvbn-ruby/pull/45

## [1.2.0] - 2021-01-05

### Added
 - Support for Ruby 3 (thanks [@RSO] ([#32]))

### Changed
 - Use [mini\_racer] for running JavaScript specs (thanks [@RSO] ([#33]))
 - Moved CI to GitHub Actions ([#34])

[1.2.0]: https://github.com/envato/zxcvbn-ruby/compare/v1.1.0...v1.2.0
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
