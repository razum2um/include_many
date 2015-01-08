module ActiveRecord
  module Associations
    class AssociationScope
      safe_monkeypatch :add_constraints, md5: 'fa15ef6f1cd4fb164746dc2bb3dcb887'

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
              key = reflection.association_primary_key(self.klass)
            else
              key = reflection.association_primary_key
            end

            foreign_key = reflection.foreign_key
          else
            key         = reflection.foreign_key
            foreign_key = reflection.active_record_primary_key
          end

          if reflection == chain.last
            bind_arel = if foreign_key.respond_to?(:call)
              fk = foreign_key.call(owner)
              if fk.respond_to?(:each)
                bind_vals = fk.compact.map do |f|
                  bind scope, table.table_name, key.to_s, f
                end
                table[key].in(bind_vals)
              else
                bind_val = bind scope, table.table_name, key.to_s, fk
                table[key].eq(bind_val)
              end
            else
              value    = owner.class.base_class.name
              bind_val = bind scope, table.table_name, reflection.type.to_s, value
              table[reflection.type].eq(bind_val)
            end
            scope    = scope.where(bind_arel)

            if reflection.type
              value    = owner.class.base_class.name
              bind_val = bind scope, table.table_name, reflection.type.to_s, value
              scope    = scope.where(table[reflection.type].eq(bind_val))
            end
          else
            constraint = table[key].eq(foreign_table[foreign_key])

            if reflection.type
              type = chain[i + 1].klass.base_class.name
              constraint = constraint.and(table[reflection.type].eq(type))
            end

            scope = scope.joins(join(foreign_table, constraint))
          end

          is_first_chain = i == 0
          klass = is_first_chain ? self.klass : reflection.klass

          # Exclude the scope of the association itself, because that
          # was already merged in the #scope method.
          scope_chain[i].each do |scope_chain_item|
            item  = eval_scope(klass, scope_chain_item)

            if scope_chain_item == self.reflection.scope
              scope.merge! item.except(:where, :includes)
            end

            if is_first_chain
              scope.includes! item.includes_values
            end

            scope.where_values += item.where_values
            scope.order_values |= item.order_values
          end
        end

        scope
      end
    end
  end
end

