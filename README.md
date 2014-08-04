# IncludesMany

[![Gem Version][GV img]][Gem Version]
[![Build Status][BS img]][Build Status]

This implements [rails/rails#16277](https://github.com/rails/rails/pull/16277) as a Gem.

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

1. Fork it ( https://github.com/razum2um/includes_many/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Acknoledgements

Thanks for [@pat](https://github.com/pat) for `combustion` and multi-rails testing practices.

[Gem Version]: https://rubygems.org/gems/include_many
[Build Status]: https://travis-ci.org/razum2um/include_many

[GV img]: https://badge.fury.io/rb/include_many.png
[BS img]: https://travis-ci.org/razum2um/include_many.png
