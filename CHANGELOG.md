# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
 - Support for Ruby 2.7 [[#29]]
 - Gem metadata [[#29]]

### Removed
 - Support for Ruby 2.3 [[#29]]
 - Support for Ruby 2.4 [[#29]]

[29]: https://github.com/envato/zxcvbn-ruby/pull/29


## [1.0.0] - 2019-05-14
### Added
Adds more ported password checking features to bring this gem more up to date.
spatial - Keyboard patterns
repeat - Repeated characters
sequence - easily guessable sequences
date - date associations
[PR for further details](https://github.com/envato/zxcvbn-ruby/pull/22)

### Removed
- This gem will no longer run on Ruby versions < 2.3
