module ActiveRecord
  class NonScalarPrimaryKeyError < ActiveRecordError
    def initialize(reflection)
      super("Can not join association #{reflection.name.inspect}, because :primary_key is a callable. Use Relation#includes or specify a join column name")
    end
  end

  module Associations
    class JoinDependency
      class JoinAssociation
        safe_monkeypatch :initialize, md5: '2332c88140aa9e9efa96975fd48e6958'

        def initialize(reflection, children)

          # PATCH here
          if reflection.options[:primary_key].respond_to?(:call)
            raise NonScalarPrimaryKeyError.new(reflection)
          end
          # end PATCH

          super(reflection.klass, children)

          @reflection      = reflection
          @tables          = nil
        end
      end
    end
  end
end

