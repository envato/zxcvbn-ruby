# zxcvbn-ruby

This is a Ruby port of Dropbox's [zxcvbn.js][zxcvbn.js] JavaScript library, targeting **zxcvbn.js v4** and aiming to produce identical results.

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
#<data Zxcvbn::Score
 password="@lfred2004",
 guesses=15000.0,
 sequence=
  [#<data Zxcvbn::Match
    pattern="dictionary",
    i=0,
    j=5,
    token="@lfred",
    matched_word="alfred",
    rank=1,
    dictionary_name="user_inputs",
    l33t=true,
    sub={"@" => "a"},
    sub_display="@ -> a",
    guesses=50,
    guesses_log10=1.6989700043360187,
    base_guesses=1,
    uppercase_variations=1,
    l33t_variations=2>,
   #<data Zxcvbn::Match
    pattern="year",
    i=6,
    j=9,
    token="2004",
    guesses=50,
    guesses_log10=1.6989700043360187>],
 crack_times_seconds=
  {"online_throttling_100_per_hour" => 540000.0,
   "online_no_throttling_10_per_second" => 1500.0,
   "offline_slow_hashing_1e4_per_second" => 1.5,
   "offline_fast_hashing_1e10_per_second" => 1.5e-06},
 crack_times_display=
  {"online_throttling_100_per_hour" => "6 days",
   "online_no_throttling_10_per_second" => "25 minutes",
   "offline_slow_hashing_1e4_per_second" => "2 seconds",
   "offline_fast_hashing_1e10_per_second" => "less than a second"},
 score=1,
 calc_time=0.0007990000303834677,
 feedback=
  #<data Zxcvbn::Feedback
   warning="",
   suggestions=
    ["Add another word or two. Uncommon words are better.",
     "Predictable substitutions like '@' instead of 'a' don't help very much"]>>
>> pp Zxcvbn.test('asdfghju7654rewq', ['alfred'])
#<data Zxcvbn::Score
 password="asdfghju7654rewq",
 guesses=923189026.4430684,
 sequence=
  [#<data Zxcvbn::Match
    pattern="spatial",
    i=0,
    j=15,
    token="asdfghju7654rewq",
    guesses=923189025.4430684,
    guesses_log10=8.965290633097352,
    graph="qwerty",
    turns=5,
    shifted_count=0>],
 crack_times_seconds=
  {"online_throttling_100_per_hour" => 33234804951.950462,
   "online_no_throttling_10_per_second" => 92318902.64430684,
   "offline_slow_hashing_1e4_per_second" => 92318.90264430684,
   "offline_fast_hashing_1e10_per_second" => 0.09231890264430684},
 crack_times_display=
  {"online_throttling_100_per_hour" => "centuries",
   "online_no_throttling_10_per_second" => "3 years",
   "offline_slow_hashing_1e4_per_second" => "1 day",
   "offline_fast_hashing_1e10_per_second" => "less than a second"},
 score=3,
 calc_time=0.001090999983716756,
 feedback=#<data Zxcvbn::Feedback warning="" suggestions=[]>>
```

## Custom Testers

`Zxcvbn.test` reuses a shared `Tester` internally — dictionaries are loaded once and persist in memory. Use `Zxcvbn.tester.build` to construct a standalone `Tester` you control:

```ruby
$ irb
>> require 'zxcvbn'
=> true
>> tester = Zxcvbn.tester.build
=> #<Zxcvbn::Tester:0x3fe99d869aa4>
>> pp tester.test('@lfred2004', ['alfred'])
#<data Zxcvbn::Score
 password="@lfred2004",
 guesses=15000.0,
 sequence=
  [#<data Zxcvbn::Match
    pattern="dictionary",
    i=0,
    j=5,
    token="@lfred",
    matched_word="alfred",
    rank=1,
    dictionary_name="user_inputs",
    l33t=true,
    sub={"@" => "a"},
    sub_display="@ -> a",
    guesses=50,
    guesses_log10=1.6989700043360187,
    base_guesses=1,
    uppercase_variations=1,
    l33t_variations=2>,
   #<data Zxcvbn::Match
    pattern="year",
    i=6,
    j=9,
    token="2004",
    guesses=50,
    guesses_log10=1.6989700043360187>],
 crack_times_seconds=
  {"online_throttling_100_per_hour" => 540000.0,
   "online_no_throttling_10_per_second" => 1500.0,
   "offline_slow_hashing_1e4_per_second" => 1.5,
   "offline_fast_hashing_1e10_per_second" => 1.5e-06},
 crack_times_display=
  {"online_throttling_100_per_hour" => "6 days",
   "online_no_throttling_10_per_second" => "25 minutes",
   "offline_slow_hashing_1e4_per_second" => "2 seconds",
   "offline_fast_hashing_1e10_per_second" => "less than a second"},
 score=1,
 calc_time=0.0008110000053420663,
 feedback=
  #<data Zxcvbn::Feedback
   warning="",
   suggestions=
    ["Add another word or two. Uncommon words are better.",
     "Predictable substitutions like '@' instead of 'a' don't help very much"]>>
```

To add custom word lists, chain `add_word_list` before `build`. Use a distinct name (e.g. `"company"`) — using a built-in name (`"english_wikipedia"`, `"passwords"`, `"female_names"`, `"male_names"`, `"surnames"`, `"us_tv_and_film"`) replaces that list entirely:

```ruby
>> tester = Zxcvbn.tester.add_word_list('company', %w[acme corp]).build
=> #<Zxcvbn::Tester:0x3fe99d869bb8>
>> tester.test('acme').score
=> 0
```

Subsequent calls reuse the already-loaded dictionaries, so `calc_time` is significantly lower:

```ruby
>> tester.test('@lfred2004', ['alfred']).calc_time
=> 0.0005759999621659517
```

> [!WARNING]
> Scoring time grows with password length. For adversarial inputs such as
> short repeated sequences (e.g. `"ab" * 500`), the internal pattern-matching
> DP produces super-quadratic runtime. Both `Zxcvbn.test` and
> `Zxcvbn::Tester#test` raise `Zxcvbn::PasswordTooLong` for passwords longer
> than 256 characters (the default). Override the
> limit with the `ZXCVBN_MAX_PASSWORD_LENGTH` environment variable, but be
> aware that raising it re-exposes this runtime risk. The `user_inputs`
> parameter is not length-bounded; apply your own limit to those values.

> [!WARNING]
> Storing the guesses or score for an encrypted or hashed value provides
> information that can make cracking the value orders of magnitude easier for an
> attacker. For this reason we advise you not to store the results of
> `Zxcvbn::Tester#test`. Further reading: [A Tale of Security Gone Wrong](https://web.archive.org/web/20240715041147/http://gavinmiller.io/2016/a-tale-of-security-gone-wrong/).

## Migrating from 1.x

Version 2 aligns with the zxcvbn.js v4 algorithm and API. Scores will change for many passwords — this is expected. The sections below cover every breaking API change.

### Ruby version

Ruby 3.3 or later is required.

### `Score` field changes

The following attributes have been removed and will raise `NoMethodError`. Use the 2.x equivalents below:

| Removed (1.x) | 2.x equivalent |
|-----|-----|
| `result.entropy` | `Math.log2(result.guesses)` or `result.guesses_log10 * Math.log2(10)` |
| `result.crack_time` | `result.crack_times_seconds["online_no_throttling_10_per_second"]` (see [Attack scenarios](#attack-scenarios)) |
| `result.crack_time_display` | `result.crack_times_display["online_no_throttling_10_per_second"]` |
| `result.match_sequence` | `result.sequence` |

1.x `crack_time` used 10 guesses/second (unthrottled online), corresponding to the `"online_no_throttling_10_per_second"` scenario. The entropy formula gives the same log-scale difficulty value, but the number will differ from 1.x because the underlying guessing algorithm has been rewritten.

`Score` is now an immutable value object. Attribute setters (`calc_time=`, `feedback=`, etc.) have been removed. Use `result.with` to create a modified copy — `with` returns a **new** frozen object:

```ruby
# 1.x
result.calc_time = 0.001

# 2.x
result = result.with(calc_time: 0.001)
```

#### Attack scenarios

`crack_times_seconds` and `crack_times_display` are both hashes keyed by attack scenario:

```ruby
result.crack_times_display
# => {
#   "online_throttling_100_per_hour"       => "6 days",
#   "online_no_throttling_10_per_second"   => "25 minutes",
#   "offline_slow_hashing_1e4_per_second"  => "2 seconds",
#   "offline_fast_hashing_1e10_per_second" => "less than a second"
# }
```

### `Match` field changes

The following attributes have been removed and will raise `NoMethodError`. Use the 2.x equivalents below:

| Removed (1.x) | 2.x equivalent |
|-----|-----|
| `match.entropy` | `match.guesses_log10 * Math.log2(10)` |
| `match.base_entropy` | `Math.log2(match.base_guesses)` (dictionary matches only — `base_guesses` is `nil` for other patterns) |
| `match.uppercase_entropy` | `Math.log2(match.uppercase_variations)` (dictionary matches only — `uppercase_variations` is `nil` for other patterns) |
| `match.l33t_entropy` | `Math.log2(match.l33t_variations)` (dictionary matches only — `l33t_variations` is `nil` for other patterns) |
| `match.repeated_char` | `match.base_token` (now supports multi-character repeating units e.g. `"abcabc"`) |
| `match.to_hash` | `match.to_h` — note: keys are now symbols (not strings), all 28 attributes are included (not just those that were set), and key order follows member definition rather than alphabetical. To replicate old behaviour: `match.to_h.transform_keys(&:to_s).compact.sort.to_h` |

These translations give a log-scale difficulty value but are not numerically equivalent to 1.x — the underlying guess estimation formulas have been rewritten.

`Match` is now an immutable value object. Attribute setters have been removed. Use `match.with(attr: value)` to derive a modified copy. Any code that splatted a match (`**match`) or passed it to `Hash()` will now raise `TypeError` — use `match.to_h` explicitly instead.

### `Feedback` changes

`Feedback#warning` now returns `''` instead of `nil` when no warning applies. Update `nil` checks accordingly:

```ruby
# 1.x
if result.feedback.warning
  show_warning(result.feedback.warning)
end

# 2.x
unless result.feedback.warning.empty?
  show_warning(result.feedback.warning)
end
```

Also update any `||` defaults on `warning` — `''` is truthy so the fallback no longer fires:

```ruby
# 1.x — worked because nil is falsy
label = result.feedback.warning || "No issues"

# 2.x
label = result.feedback.warning.empty? ? "No issues" : result.feedback.warning
```

The "This is similar to a commonly used password" warning is now only emitted when `match.guesses_log10 <= 4` (previously it applied to any l33t, reversed, or non-sole-match on the passwords dictionary). Update any code that asserts on feedback content.

`Feedback` is now an immutable value object. Attribute setters (`warning=`, `suggestions=`) have been removed. Use `result.feedback.with(warning: "...")` to derive a modified copy.

### Dictionary name change

The `english` frequency list has been renamed to `english_wikipedia`. If you filter matches by `dictionary_name`:

```ruby
# 1.x
match.dictionary_name == "english"

# 2.x
match.dictionary_name == "english_wikipedia"
```

A new `us_tv_and_film` frequency list has also been added. Update any `dictionary_name` allowlists or case statements to include it.

### Password length limit

`Tester#test` and `Zxcvbn.test` now raise `Zxcvbn::PasswordTooLong` (a subclass of `ArgumentError`) for passwords longer than 256 characters (the default). Previously, long passwords were accepted without error. The `user_inputs` parameter remains unbounded.

If your application accepts user-controlled input longer than 256 characters, either add a length check before calling the gem, construct a `Tester` with a custom limit, or adjust the process-wide default via the `ZXCVBN_MAX_PASSWORD_LENGTH` environment variable.

To enforce your own limit before calling the gem (note: bcrypt's limit is 72 **bytes**, not characters):

```ruby
raise ArgumentError, "Password too long" if password.bytesize > 72 # bcrypt's 72-byte limit
result = Zxcvbn.test(password)
```

To use a different limit for a specific tester without touching the environment:

```ruby
tester = Zxcvbn.tester.max_password_length(128).build
result = tester.test(password)
```

To adjust the process-wide default, set `ZXCVBN_MAX_PASSWORD_LENGTH` in the process environment before the process starts:

```sh
ZXCVBN_MAX_PASSWORD_LENGTH=1024 bundle exec rails server
```

The variable is read when `TesterBuilder#build` is called. For the shared tester backing `Zxcvbn.test`, that is the first call to `Zxcvbn.test`.

Or export it from your shell profile, process manager, or platform environment config (Heroku, Docker, etc.). Note that raising the limit re-exposes the super-quadratic runtime for adversarial inputs to the `password` argument.

### Custom word lists

`Tester#add_word_lists` and the `word_lists:` argument to `Zxcvbn.test` have been removed. Use the `Zxcvbn.tester` builder instead:

```ruby
# 1.x — no longer works
result = Zxcvbn.test(password, user_inputs, word_lists: { 'company' => %w[acme corp] })
tester.add_word_lists('company' => %w[acme corp])

# 2.x
tester = Zxcvbn.tester.add_word_list('company', %w[acme corp]).build
result = tester.test(password, user_inputs)
```

`Zxcvbn::Tester.new` is no longer a public construction path — it now requires `data:` and `max_password_length:` keyword arguments with no defaults. Use `Zxcvbn.tester.build` (or the fluent builder) instead:

```ruby
# 1.x
tester = Zxcvbn::Tester.new

# 2.x
tester = Zxcvbn.tester.build
```

### Score values will change

The scoring algorithm has been rewritten to match zxcvbn.js v4. It now minimises total guesses rather than entropy bits. Bruteforce cardinality is fixed at 10 regardless of the character classes in the password (previously 10–95 depending on which character classes were present). Scores (0–4) for many passwords will differ from 1.x — this is expected and intentional.

Audit any code that gates on `result.score` (e.g. form validation thresholds), persists scores in a database, or asserts on score values in tests — these will need review after upgrading.

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
