# zxcvbn-ruby

Ruby port of [zxcvbn.js](https://github.com/dropbox/zxcvbn)

## Usage

Gemfile:

```ruby
gem "zxcvbn-ruby", :require => 'zxcvbn'
```

Example usage:

```ruby
require 'zxcvbn'

class User < Struct.new(:username, :password)
  def password_strength
    Zxcvbn.test(password, [username, 'sitename'])
  end
end

>> User.new('alfred', '@lfred2004').password_strength
# => #<Zxcvbn::Score:0x007fafd0c779a0 @entropy=7.895, @crack_time=0.012, @crack_time_display="instant", @score=0, @match_sequence=[#<Zxcvbn::Match matched_word="alfred", token="@lfred", i=0, j=5, rank=1, pattern="dictionary", dictionary_name="user_inputs", l33t=true, sub={"@"=>"a"}, sub_display="@ -> a", base_entropy=0.0, uppercase_entropy=0.0, l33t_entropy=1, entropy=1.0>, #<Zxcvbn::Match i=6, j=9, token="2004", pattern="year", entropy=6.894817763307944>], @password="@lfred2004", @calc_time=0.003048>

>> User.new('alfred', 'asdfghju7654rewq').password_strength
# => #<Zxcvbn::Score:0x007fcf3b563558 @entropy=29.782, @crack_time=46159.451, @crack_time_display="14 hours", @score=2, @match_sequence=[#<Zxcvbn::Match pattern="spatial", i=0, j=15, token="asdfghju7654rewq", graph="qwerty", turns=5, shifted_count=0, entropy=29.7820508329166>], @password="asdfghju7654rewq", @calc_time=0.005015>
```