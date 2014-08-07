module ActiveRecord
  module Associations
    class Preloader
      class HasMany
        safe_monkeypatch :association_key_name, md5: 'c4a2d2c69f85b007bf546989d601b94a'

        # method is fully rewritten
        def association_key_name
          fk = reflection.foreign_key
          if fk.respond_to?(:call)
            fk.call(owners.first)
          else
            fk
          end
        end

        safe_monkeypatch :owners_by_key, md5: '33eab3037fd994d4a7106a68a05f169d'

        # method is fully rewritten
        def owners_by_key
          @owners_by_key ||= begin
            res = Hash.new { |h,k| h[k] = Set.new }
            owners.each do |owner|
              key = if owner_key_name.respond_to?(:call)
                owner_key_name.call(owner)
              else
                owner[owner_key_name]
              end

              if key.respond_to?(:each)
                key.each { |k| res[k && k.to_s] << owner }
              else
                res[key && key.to_s] << owner
              end
            end
            res
          end
        end
      end
    end
  end
end

