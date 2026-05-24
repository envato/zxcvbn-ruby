# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
 - `Zxcvbn::Guesses` module with per-pattern guess estimation formulas matching zxcvbn.js v4: bruteforce, dictionary (with uppercase and l33t variation multipliers), spatial, repeat, sequence, digits, year, and date ([#69])
 - `us_tv_and_film` frequency list (19,160 entries) introduced in zxcvbn.js v4 ([#69])
 - Reverse dictionary matching in `Omnimatch` so reversed words (e.g. "drowssap") are detected and scored ([#69])
 - `guesses` field on `Zxcvbn::Score` ([#69])
 - `guesses`, `guesses_log10`, `base_token`, `repeat_count`, and `base_guesses` fields on `Zxcvbn::Match` ([#69])

### Changed
 - **Breaking**: Scoring algorithm aligned with zxcvbn.js v4.4.2. The dynamic programming step now minimises total guesses (`factorial(l) × cumulative_product + MIN_GUESSES^(l-1)` penalty) instead of entropy bits. Scores for many passwords will change ([#69])
 - **Breaking**: Bruteforce cardinality is now fixed at 10 (digits only), matching zxcvbn.js v4. Previously it was computed dynamically from the character classes present in the password (10–95), so bruteforce guesses for passwords containing letters or symbols will change ([#69])
 - **Breaking**: `Repeat` matcher now detects multi-character repeating units (e.g. `abcabc`). The `base_token` field holds the repeating unit (which may be more than one character); `repeated_char` has been removed ([#69])
 - **Breaking**: `Match#entropy`, `Match#base_entropy`, `Match#uppercase_entropy`, and `Match#l33t_entropy` have been removed. Use `Match#guesses` and `Match#guesses_log10` instead ([#69])
 - `crack_time_to_score` replaced by `guesses_to_score` with v4 thresholds: 0 (<1,005 guesses), 1 (<1,000,005), 2 (<100,000,005), 3 (<10,000,000,005), 4 (≥10,000,000,005) ([#69])
 - `Sequence` matcher ported to the zxcvbn.js v4 delta-based algorithm. Sequences are now detected using codepoint deltas up to ±5 (was ±1 only), enabling matches like `"ace"` (delta 2) or Unicode runs like `"αβγ"`. Sequence type is classified by character class (`lower`/`upper`/`digits`/`unicode`) rather than a lookup table ([#69])
 - `Date` matcher year range extended to 1000–2050; 2-digit years are now expanded (>50 → 1900s, ≤50 → 2000s) ([#69])
 - All frequency lists replaced with zxcvbn.js v4.4.2 versions: `passwords` (30k entries), `surnames` (10k), `female_names` (3,712), `male_names` (983), `english` (30k from the english_wikipedia list) ([#69])
 - **Breaking**: `entropy` on `Zxcvbn::Score` has been removed. Use `Score#guesses` or `Math.log2(score.guesses)` instead ([#69])
 - Passwords longer than 256 characters are silently truncated before scoring to bound O(n²) dictionary matching time ([#69])

[Unreleased]: https://github.com/envato/zxcvbn-ruby/compare/v1.4.0...HEAD
[#69]: https://github.com/envato/zxcvbn-ruby/pull/69

## [1.4.0] - 2026-01-15

### Added
 - RBS type signatures for improved type checking and IDE support ([#68])

### Changed
 - Minor fixups in gem metadata ([#67]).

[1.4.0]: https://github.com/envato/zxcvbn-ruby/compare/v1.3.0...v1.4.0
[#67]: https://github.com/envato/zxcvbn-ruby/pull/67
[#68]: https://github.com/envato/zxcvbn-ruby/pull/68

## [1.3.0] - 2026-01-02

### Changed
 - Replace OpenStruct with regular class in `Zxcvbn::Match` for 2x performance improvement ([#61])
 - Implement Trie data structure for dictionary matching with 1.4x additional performance improvement ([#62])
 - Replace range operators with `String#slice` for string slicing operations ([#63])
 - Optimise L33t matcher with early bailout and improved deduplication ([#64])
 - Pre-compute spatial graph statistics during data initialisation ([#65])
 - Optimise nCk calculation using symmetry property ([#66])

Overall performance improvement: 4.1x faster than v1.2.4 (0.722ms → 0.176ms per password)

[1.3.0]: https://github.com/envato/zxcvbn-ruby/compare/v1.2.4...v1.3.0
[#61]: https://github.com/envato/zxcvbn-ruby/pull/61
[#62]: https://github.com/envato/zxcvbn-ruby/pull/62
[#63]: https://github.com/envato/zxcvbn-ruby/pull/63
[#64]: https://github.com/envato/zxcvbn-ruby/pull/64
[#65]: https://github.com/envato/zxcvbn-ruby/pull/65
[#66]: https://github.com/envato/zxcvbn-ruby/pull/66

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
