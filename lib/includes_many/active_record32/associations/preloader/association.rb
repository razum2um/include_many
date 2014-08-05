module IncludesMany
  module ActiveRecord
    module Preloader
      class IncludesMany < ::ActiveRecord::Preloader::HasMany
        def association_key_name
          fk = reflection.foreign_key
          if fk.respond_to?(:call)
            fk.call(owners.first)
          else
            fk
          end
        end

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
