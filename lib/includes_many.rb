require "includes_many/version"
require "active_record"

module IncludesMany
  major, minor, patch = Gem::Version.new(ActiveRecord::VERSION::STRING).segments
  require "includes_many/active_record#{major}#{minor}"
end
