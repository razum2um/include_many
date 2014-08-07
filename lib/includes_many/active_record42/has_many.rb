module ActiveRecord
  module Associations
    class Preloader
      class HasMany
        safe_monkeypatch :owners_by_key, md5: '70b0628dd3c79928ee0bcff75052894a'

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
                key.each do |k|
                  k = k.to_s if key_conversion_required?
                  res[k] << owner
                end
              else
                key = key.to_s if key_conversion_required?
                res[key] << owner
              end
            end
            res
          end
        end
      end
    end
  end
end

