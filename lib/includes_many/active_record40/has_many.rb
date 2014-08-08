module ActiveRecord
  module Associations
    class Preloader
      class HasMany
        safe_monkeypatch :owners_by_key, md5: '33eab3037fd994d4a7106a68a05f169d'

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
                  res[k && k.to_s] << owner
                end
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

