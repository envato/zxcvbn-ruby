# RBS Type Signatures

This directory contains [RBS](https://github.com/ruby/rbs) type signatures for the zxcvbn-ruby gem.

## What is RBS?

RBS is Ruby's type signature language. It provides a way to describe the structure of Ruby programs with:
- Class and module definitions
- Method signatures with parameter and return types
- Instance variables and constants
- Duck typing and union types

## Usage

### Validating Type Signatures

To validate that the RBS files are syntactically correct:

```bash
bundle exec rake rbs:validate
```

### Runtime Type Checking

To run runtime type checking against the actual Ruby code during tests:

```bash
bundle exec rake rbs:test
```

This runs the RSpec test suite with RBS type checking enabled, verifying that method calls match their type signatures at runtime. Note: This takes about 2 minutes to run.

### Other Useful Commands

List all Zxcvbn types:
```bash
bundle exec rake rbs:list
```

Check syntax of RBS files:
```bash
bundle exec rake rbs:parse
```

## File Structure

The signatures mirror the structure of the `lib/` directory:

- `sig/zxcvbn.rbs` - Main Zxcvbn module
- `sig/zxcvbn/*.rbs` - Core classes (Tester, Score, Match, etc.)
- `sig/zxcvbn/matchers/*.rbs` - Pattern matcher classes

## Adding New Signatures

When adding new classes or methods to the codebase, remember to:

1. Create or update the corresponding `.rbs` file in the `sig/` directory
2. Run `bundle exec rake rbs_validate` to ensure the syntax is correct
3. Keep type signatures in sync with the actual implementation

## Resources

- [RBS Documentation](https://github.com/ruby/rbs)
- [RBS Syntax Guide](https://github.com/ruby/rbs/blob/master/docs/syntax.md)
- [Ruby Signature Collection](https://github.com/ruby/gem_rbs_collection)
