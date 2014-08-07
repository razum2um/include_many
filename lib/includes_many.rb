require "includes_many/version"
require "safe_monkeypatch"
require "active_record"

major, minor, _ = Gem::Version.new(ActiveRecord::VERSION::STRING).segments
require "includes_many/active_record#{major}#{minor}"

module IncludesMany
end

module ActiveRecord
  module Associations
    module ClassMethods
      module_eval do
        alias includes_many has_many
      end
    end
  end
end
