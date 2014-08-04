# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'includes_many/version'

Gem::Specification.new do |spec|
  spec.name          = "includes_many"
  spec.version       = IncludesMany::VERSION
  spec.authors       = ["Vlad Bokov"]
  spec.email         = ["razum2um@mail.ru"]
  spec.summary       = %q{ActiveRecord has_many + includes(:relation) on steroids}
  spec.description   = %q{ActiveRecord has_many + includes(:relation) on steroids}
  spec.homepage      = "https://github.com/razum2um/include_many"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 3.2", "< 4.2"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "combustion"
  spec.add_development_dependency "appraisal"
end
