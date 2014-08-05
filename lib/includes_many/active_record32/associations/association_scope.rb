module IncludesMany
  module ActiveRecord
    module Associations
      class AssociationScope < ::ActiveRecord::Associations::AssociationScope
        def add_constraints(scope)
          tables = construct_tables

          chain.each_with_index do |reflection, i|
            table, foreign_table = tables.shift, tables.first

            if reflection.source_macro == :has_and_belongs_to_many
              join_table = tables.shift

              scope = scope.joins(join(
                join_table,
                table[reflection.association_primary_key].
                  eq(join_table[reflection.association_foreign_key])
              ))

              table, foreign_table = join_table, tables.first
            end

            if reflection.source_macro == :belongs_to
              if reflection.options[:polymorphic]
                key = reflection.association_primary_key(klass)
              else
                key = reflection.association_primary_key
              end

              foreign_key = reflection.foreign_key
            else
              key         = reflection.foreign_key
              foreign_key = reflection.active_record_primary_key
            end

            conditions = self.conditions[i]

            # PATCH here
            if key.respond_to?(:call)
              key = key.call(owner)
            end
            # end PATCH

            if reflection == chain.last
              # PATCH here
              fk_arel = if foreign_key.respond_to?(:call)
                fk = foreign_key.call(owner)
                if fk.respond_to?(:each)
                  table[key].in(fk.compact)
                else
                  table[key].eq(fk)
                end
              else
                table[key].eq(owner[foreign_key])
              end
              scope = scope.where(fk_arel)
              # end PATCH

              if reflection.type
                scope = scope.where(table[reflection.type].eq(owner.class.base_class.name))
              end

              conditions.each do |condition|
                if options[:through] && condition.is_a?(Hash)
                  condition = disambiguate_condition(table, condition)
                end

                scope = scope.where(interpolate(condition))
              end
            else
              constraint = table[key].eq(foreign_table[foreign_key])

              if reflection.type
                type = chain[i + 1].klass.base_class.name
                constraint = constraint.and(table[reflection.type].eq(type))
              end

              scope = scope.joins(join(foreign_table, constraint))

              unless conditions.empty?
                scope = scope.where(sanitize(conditions, table))
              end
            end
          end

          scope
        end
      end
    end
  end
end
