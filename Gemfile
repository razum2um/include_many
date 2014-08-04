source 'https://rubygems.org'

# Specify your gem's dependencies in includes_many.gemspec
gemspec

unless ENV['TRAVIS']
  group :development do
    # tools
    gem 'debugger', github: 'razum2um/debugger'
    gem 'pry-debugger'
    gem 'pry-stack_explorer'
    # rspec --format fuubar
    gem 'fuubar'
  end
end
