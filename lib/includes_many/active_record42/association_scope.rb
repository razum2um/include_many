module ActiveRecord
  module Associations
    class AssociationScope
      safe_monkeypatch :add_constraints, md5: '191225b52dbc5ff8fd658b76a9b9b840', error: 'fails on Fri Aug 8 16:10:06 2014 +0200 f4c8ce9'

      def add_constraints(scope, owner, assoc_klass, refl, tracker)
        chain = refl.chain
        scope_chain = refl.scope_chain

        tables = construct_tables(chain, assoc_klass, refl, tracker)

        chain.each_with_index do |reflection, i|
          table, foreign_table = tables.shift, tables.first

          join_keys = reflection.join_keys(assoc_klass)
          key = join_keys.key
          foreign_key = join_keys.foreign_key

          if reflection == chain.last
            bind_arel = if foreign_key.respond_to?(:call)
              fk = foreign_key.call(owner)
              if fk.respond_to?(:each)
                bind_vals = fk.compact.map do |f|
                  bind scope, table.table_name, key.to_s, f, tracker
                end
                table[key].in(bind_vals)
              else
                bind_val = bind scope, table.table_name, key.to_s, fk, tracker
                table[key].eq(bind_val)
              end
            else
              bind_val = bind scope, table.table_name, key.to_s, owner[foreign_key], tracker
              table[key].eq(bind_val)
            end
            scope = scope.where(bind_arel)

            if reflection.type
              value    = owner.class.base_class.name
              bind_val = bind scope, table.table_name, reflection.type.to_s, value, tracker
              scope    = scope.where(table[reflection.type].eq(bind_val))
            end
          else
            constraint = table[key].eq(foreign_table[foreign_key])

            if reflection.type
              value    = chain[i + 1].klass.base_class.name
              bind_val = bind scope, table.table_name, reflection.type.to_s, value, tracker
              scope    = scope.where(table[reflection.type].eq(bind_val))
            end

            scope = scope.joins(join(foreign_table, constraint))
          end

          is_first_chain = i == 0
          klass = is_first_chain ? assoc_klass : reflection.klass

          # Exclude the scope of the association itself, because that
          # was already merged in the #scope method.
          scope_chain[i].each do |scope_chain_item|
            item  = eval_scope(klass, scope_chain_item, owner)

            if scope_chain_item == refl.scope
              scope.merge! item.except(:where, :includes, :bind)
            end

            if is_first_chain
              scope.includes! item.includes_values
            end

            scope.where_values += item.where_values
            scope.bind_values  += item.bind_values
            scope.order_values |= item.order_values
          end
        end

        scope
      end
    end
  end
end

