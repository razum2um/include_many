# IncludesMany

[![Gem Version][GV img]][Gem Version]
[![Build Status][BS img]][Build Status]

This implements [rails/rails#16277](https://github.com/rails/rails/pull/16277) as a Gem.
Tested with Rails 3.2.19, 4.0.8, 4.1.4 :)

Sad, but ActiveRecord is hard to extend :( I used monkeypatch,
but it's protected by [`safe_monkeypatch`](https://github.com/razum2um/safe_monkeypatch)
It will loudly complain at startup time if it's incompatible. Feel free to open an issue if such.

Use it and upgrade without fear!

## Usage

Use `includes_many` in your AR-model:

    includes_many :siblings_and_children, :class_name => 'Comment',
       :foreign_key => :parent_id, :primary_key => proc { |c| [c.parent_id, c.id] }

And do eager loading:

    comments = Comment.where(body: 'something').includes(:siblings_and_children)
    comments.map(&:siblings_and_children) # ...

This would issue only 2 SQL queries just as expected.

Normally, without this gem you would write an instance method `siblings_and_children`
and calling a method would end up with an N+1 problem.

## Installation

Add my public key:

    gem cert --add <(curl -Ls https://raw.github.com/razum2um/include_many/master/certs/razum2um.pem)

    $ gem install include_many                 # without key
    $ gem install include_many -P HighSecurity # secure, with key added

Add this line to your application's Gemfile:

    gem 'includes_many'

## Contributing

To test under different Rails version use [`appraisal`](https://github.com/thoughtbot/appraisal)
To experiment inside a console:

    appraisal rails_3_2 rake c # etc..

1. Fork it ( https://github.com/razum2um/includes_many/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Acknoledgements

Thanks for [@pat](https://github.com/pat) for `combustion` and multi-rails testing practices.

[Gem Version]: https://rubygems.org/gems/includes_many
[Build Status]: https://travis-ci.org/razum2um/includes_many

[GV img]: https://badge.fury.io/rb/includes_many.png
[BS img]: https://travis-ci.org/razum2um/includes_many.png
