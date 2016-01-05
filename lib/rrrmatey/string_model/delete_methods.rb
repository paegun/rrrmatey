module RRRMatey
    module StringModel
        module DeleteMethods
            def delete(id)
                return 0 if cache_proxy.nil?
                cache_proxy.with { |r|
                    r.del(self.namespaced_key(id))
                }
            end
        end
    end
end
