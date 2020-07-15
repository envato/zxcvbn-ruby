# zxcvbn-ruby

This is a Ruby port of Dropbox's [zxcvbn.js](https://github.com/dropbox/zxcvbn) JavaScript library.

## Development status [![Build Status](https://travis-ci.org/envato/zxcvbn-ruby.svg?branch=master)](https://travis-ci.org/envato/zxcvbn-ruby)

`zxcvbn-ruby` is considered stable and is used in projects around [Envato][envato].

After checking out the repository, run `bundle install` to install dependencies.
Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).


## Getting started [![Gem version](https://img.shields.io/gem/v/zxcvbn-ruby.svg?style=flat-square)](https://github.com/envato/zxcvbn-ruby) [![Gem downloads](https://img.shields.io/gem/dt/zxcvbn-ruby.svg?style=flat-square)](https://rubygems.org/gems/zxcvbn-ruby)

Add the following to your project's `Gemfile`:

```ruby
gem 'zxcvbn-ruby', require: 'zxcvbn'
```

Example usage:

```ruby
$ irb
>> require 'zxcvbn'
=> true
>> pp Zxcvbn.test('@lfred2004', ['alfred'])
#<Zxcvbn::Score:0x00007f7f590610c8
 @calc_time=0.0055760000250302255,
 @crack_time=0.012,
 @crack_time_display="instant",
 @entropy=7.895,
 @feedback=
  #<Zxcvbn::Feedback:0x00007f7f59060150
   @suggestions=
    ["Add another word or two. Uncommon words are better.",
     "Predictable substitutions like '@' instead of 'a' don't help very much"],
   @warning=nil>,
 @match_sequence=
  [#<Zxcvbn::Match matched_word="alfred", token="@lfred", i=0, j=5, rank=1, pattern="dictionary", dictionary_name="user_inputs", l33t=true, sub={"@"=>"a"}, sub_display="@ -> a", base_entropy=0.0, uppercase_entropy=0.0, l33t_entropy=1, entropy=1.0>,
   #<Zxcvbn::Match i=6, j=9, token="2004", pattern="year", entropy=6.894817763307944>],
 @password="@lfred2004",
 @score=0>
=> #<Zxcvbn::Score:0x00007f7f59060150>
>> pp Zxcvbn.test('asdfghju7654rewq', ['alfred'])
#<Zxcvbn::Score:0x00007f7f5a9e9248
 @calc_time=0.007504999986849725,
 @crack_time=46159.451,
 @crack_time_display="14 hours",
 @entropy=29.782,
 @feedback=
  #<Zxcvbn::Feedback:0x00007f7f5a9e9130
   @suggestions=
    ["Add another word or two. Uncommon words are better.",
     "Use a longer keyboard pattern with more turns"],
   @warning="Short keyboard patterns are easy to guess">,
 @match_sequence=
  [#<Zxcvbn::Match pattern="spatial", i=0, j=15, token="asdfghju7654rewq", graph="qwerty", turns=5, shifted_count=0, entropy=29.7820508329166>],
 @password="asdfghju7654rewq",
 @score=2>
=> #<Zxcvbn::Score:0x00007f7f5a9e9248>
```

## Testing Multiple Passwords

The dictionaries used for password strength testing are loaded each request to `Zxcvbn.test`. If you you'd prefer to persist the dictionaries in memory (approx 20MB RSS) to perform lots of password tests in succession then you can use the `Zxcvbn::Tester` API:

```ruby
$ irb
>> require 'zxcvbn'
=> true
>> tester = Zxcvbn::Tester.new
=> #<Zxcvbn::Tester:0x3fe99d869aa4>
>> pp tester.test('@lfred2004', ['alfred'])
#<Zxcvbn::Score:0x00007f7f586fcf50
 @calc_time=0.00631899997824803,
 @crack_time=0.012,
 @crack_time_display="instant",
 @entropy=7.895,
 @feedback=
  #<Zxcvbn::Feedback:0x00007f7f586fcac8
   @suggestions=
    ["Add another word or two. Uncommon words are better.",
     "Predictable substitutions like '@' instead of 'a' don't help very much"],
   @warning=nil>,
 @match_sequence=
  [#<Zxcvbn::Match matched_word="alfred", token="@lfred", i=0, j=5, rank=1, pattern="dictionary", dictionary_name="user_inputs", l33t=true, sub={"@"=>"a"}, sub_display="@ -> a", base_entropy=0.0, uppercase_entropy=0.0, l33t_entropy=1, entropy=1.0>,
   #<Zxcvbn::Match i=6, j=9, token="2004", pattern="year", entropy=6.894817763307944>],
 @password="@lfred2004",
 @score=0>
=> #<Zxcvbn::Score:0x00007f7f586fcf50>
>> pp tester.test('@lfred2004', ['alfred'])
#<Zxcvbn::Score:0x00007f7f56d57438
 @calc_time=0.001986999996006489,
 @crack_time=0.012,
 @crack_time_display="instant",
 @entropy=7.895,
 @feedback=
  #<Zxcvbn::Feedback:0x00007f7f56d56bf0
   @suggestions=
    ["Add another word or two. Uncommon words are better.",
     "Predictable substitutions like '@' instead of 'a' don't help very much"],
   @warning=nil>,
 @match_sequence=
  [#<Zxcvbn::Match matched_word="alfred", token="@lfred", i=0, j=5, rank=1, pattern="dictionary", dictionary_name="user_inputs", l33t=true, sub={"@"=>"a"}, sub_display="@ -> a", base_entropy=0.0, uppercase_entropy=0.0, l33t_entropy=1, entropy=1.0>,
   #<Zxcvbn::Match i=6, j=9, token="2004", pattern="year", entropy=6.894817763307944>],
 @password="@lfred2004",
 @score=0>
=> #<Zxcvbn::Score:0x00007f7f56d57438>
```

**Note**: Storing the entropy of an encrypted or hashed value provides
information that can make cracking the value orders of magnitude easier for an
attacker. For this reason we advise you not to store the results of
`Zxcvbn::Tester#test`. Further reading: [A Tale of Security Gone Wrong](http://gavinmiller.io/2016/a-tale-of-security-gone-wrong/).

## Contact

 - [GitHub project](https://github.com/envato/zxcvbn-ruby)
 - Bug reports and feature requests are welcome via [GitHub Issues](https://github.com/envato/zxcvbn-ruby/issues)

## Maintainers

 - [Pete Johns](https://github.com/johnsyweb)
 - [Steve Hodgkiss](https://github.com/stevehodgkiss)

## Authors

 - [Steve Hodgkiss](https://github.com/stevehodgkiss)
 - [Matthieu Aussaguel](https://github.com/matthieua)
 - [_et al._](https://github.com/envato/zxcvbn-ruby/graphs/contributors)

 [envato]: https://envato.com?utm_source=github
