require "includes_many/version"
require "active_record"

module IncludesMany
  major, minor, _ = Gem::Version.new(ActiveRecord::VERSION::STRING).segments
  require "includes_many/active_record#{major}#{minor}"
end
