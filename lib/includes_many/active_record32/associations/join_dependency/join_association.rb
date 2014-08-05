module IncludesMany
  module ActiveRecord
    module Associations
      class NonScalarPrimaryKeyError < ActiveRecordError
        def initialize(reflection)
          super("Can not join association #{reflection.name.inspect}, because :primary_key is a callable. Use Relation#includes or specify a join column name")
        end
      end

      class JoinDependency
        class NoJoinAssociation < ::ActiveRecord::Associations::JoinDependency::JoinAssociation # < JoinPart
          def initialize(reflection, join_dependency, parent = nil)
            binding.pry
            super

            reflection.check_validity!

            # PATCH here
            if reflection.options[:primary_key].respond_to?(:call)
              raise NonScalarPrimaryKeyError.new(reflection)
            end
            # end PATCH

            if reflection.options[:polymorphic]
              raise EagerLoadPolymorphicError.new(reflection)
            end

            super(reflection.klass)

            @reflection      = reflection
            @join_dependency = join_dependency
            @parent          = parent
            @join_type       = Arel::InnerJoin
            @aliased_prefix  = "t#{ join_dependency.join_parts.size }"
            @tables          = construct_tables.reverse
          end
        end

      end
    end
  end
end

