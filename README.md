# zxcvbn-ruby

This is a Ruby port of Dropbox's [zxcvbn.js][zxcvbn.js] JavaScript library.

## Development status [![CI Status](https://github.com/envato/zxcvbn-ruby/workflows/CI/badge.svg)](https://github.com/envato/zxcvbn-ruby/actions?query=workflow%3ACI)

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
 @calc_time=0.0007179999956861138,
 @crack_time=0.75,
 @crack_time_display="instant",
 @entropy=13.873,
 @feedback=
  #<Zxcvbn::Feedback:0x00007f7f59060150
   @suggestions=
    ["Add another word or two. Uncommon words are better.",
     "Predictable substitutions like '@' instead of 'a' don't help very much"],
   @warning=nil>,
 @guesses=15000,
 @match_sequence=
  [#<Zxcvbn::Match:0x00007f7f59060200
    @base_guesses=1,
    @dictionary_name="user_inputs",
    @guesses=50,
    @guesses_log10=1.6989700043360187,
    @i=0,
    @j=5,
    @l33t=true,
    @l33t_variations=2,
    @matched_word="alfred",
    @pattern="dictionary",
    @rank=1,
    @sub={"@" => "a"},
    @sub_display="@ -> a",
    @token="@lfred",
    @uppercase_variations=1>,
   #<Zxcvbn::Match:0x00007f7f59060300
    @guesses=50,
    @guesses_log10=1.6989700043360187,
    @i=6,
    @j=9,
    @pattern="year",
    @token="2004">],
 @password="@lfred2004",
 @score=1>
=> #<Zxcvbn::Score:0x00007f7f590610c8>
>> pp Zxcvbn.test('asdfghju7654rewq', ['alfred'])
#<Zxcvbn::Score:0x00007f7f5a9e9248
 @calc_time=0.0011630000080913305,
 @crack_time=46159.451,
 @crack_time_display="14 hours",
 @entropy=29.782,
 @feedback=
  #<Zxcvbn::Feedback:0x00007f7f5a9e9130
   @suggestions=[],
   @warning=nil>,
 @guesses=923189026.4430684,
 @match_sequence=
  [#<Zxcvbn::Match:0x00007f7f5a9e9000
    @graph="qwerty",
    @guesses=923189025.4430684,
    @guesses_log10=8.965290633097352,
    @i=0,
    @j=15,
    @pattern="spatial",
    @shifted_count=0,
    @token="asdfghju7654rewq",
    @turns=5>],
 @password="asdfghju7654rewq",
 @score=3>
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
 @calc_time=0.006318999978248030,
 @crack_time=0.75,
 @crack_time_display="instant",
 @entropy=13.873,
 @feedback=
  #<Zxcvbn::Feedback:0x00007f7f586fcac8
   @suggestions=
    ["Add another word or two. Uncommon words are better.",
     "Predictable substitutions like '@' instead of 'a' don't help very much"],
   @warning=nil>,
 @guesses=15000,
 @match_sequence=
  [#<Zxcvbn::Match:0x00007f7f586fc900
    @base_guesses=1,
    @dictionary_name="user_inputs",
    @guesses=50,
    @guesses_log10=1.6989700043360187,
    @i=0,
    @j=5,
    @l33t=true,
    @l33t_variations=2,
    @matched_word="alfred",
    @pattern="dictionary",
    @rank=1,
    @sub={"@" => "a"},
    @sub_display="@ -> a",
    @token="@lfred",
    @uppercase_variations=1>,
   #<Zxcvbn::Match:0x00007f7f586fc800
    @guesses=50,
    @guesses_log10=1.6989700043360187,
    @i=6,
    @j=9,
    @pattern="year",
    @token="2004">],
 @password="@lfred2004",
 @score=1>
=> #<Zxcvbn::Score:0x00007f7f586fcf50>
```

Subsequent calls reuse the already-loaded dictionaries, so `@calc_time` is significantly lower:

```ruby
>> tester.test('@lfred2004', ['alfred']).calc_time
=> 0.0009840000000596046
```

**Note**: Storing the guesses or score for an encrypted or hashed value provides
information that can make cracking the value orders of magnitude easier for an
attacker. For this reason we advise you not to store the results of
`Zxcvbn::Tester#test`. Further reading: [A Tale of Security Gone Wrong](https://web.archive.org/web/20240715041147/http://gavinmiller.io/2016/a-tale-of-security-gone-wrong/).

## Contact

 - [GitHub project](https://github.com/envato/zxcvbn-ruby)
 - Bug reports and feature requests are welcome via [GitHub Issues](https://github.com/envato/zxcvbn-ruby/issues)

## Authors

 - [Steve Hodgkiss](https://github.com/stevehodgkiss)
 - [Matthieu Aussaguel](https://github.com/matthieua)
 - [_et al._](https://github.com/envato/zxcvbn-ruby/graphs/contributors)

## License [![license](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square)](https://github.com/envato/zxcvbn-ruby/blob/HEAD/LICENSE.txt)

`zxcvbn-ruby` uses MIT license, the same as [zxcvbn.js][zxcvbn.js] itself. See
[`LICENSE.txt`](https://github.com/envato/zxcvbn-ruby/blob/HEAD/LICENSE.txt)
for details.

## Code of Conduct

We welcome contribution from everyone. Read more about it in
[`CODE_OF_CONDUCT.md`](https://github.com/envato/zxcvbn-ruby/blob/HEAD/CODE_OF_CONDUCT.md).

## Contributing [![PRs welcome](https://img.shields.io/badge/PRs-welcome-orange.svg?style=flat-square)](https://github.com/envato/zxcvbn-ruby/issues)

For bug fixes, documentation changes, and features:

1. [Fork it](./fork)
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request

For larger new features: Do everything as above, but first also make contact with the project maintainers to be sure your change fits with the project direction and you won't be wasting effort going in the wrong direction.

## About [![code with heart by Envato](https://img.shields.io/badge/%3C%2F%3E%20with%20%E2%99%A5%20by-Envato-ff69b4.svg?style=flat-square)](https://github.com/envato/zxcvbn-ruby)

This project is maintained by the Envato engineering team and funded by [Envato][envato].

Encouraging the use and creation of open source software is one of the ways we
serve our community. Perhaps [come work with us][careers]
where you'll find an incredibly diverse, intelligent and capable group of people
who help make our company succeed and make our workplace fun, friendly and
happy.

 [careers]: https://envato.com/careers/?utm_source=github
 [envato]: https://envato.com?utm_source=github
 [zxcvbn.js]: https://github.com/dropbox/zxcvbn
