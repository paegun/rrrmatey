module RRRMatey
    module StringModel
        module NamespacedKeyMethods
            def item_name()
                @item_name ||= name.underscore
            end
            
            def item_name=(v)
                @item_name = v
            end

            def namespace()
                @namespace ||= item_name.pluralize
            end

            def namespaced_key(id)
                "#{namespace}:#{id}"
            end
        end
    end
end
