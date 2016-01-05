module RRRMatey
    module StringModel
        module ConnectionMethods
            def cache_proxy()
                if @cache_proxy.nil? && self.name != RRRMatey::StringModel.name
                    return StringModel.cache_proxy
                end
                @cache_proxy
            end

            def cache_proxy=(v)
                @cache_proxy = v
            end
 
            def riak()
                if @riak.nil? && self.name != RRRMatey::StringModel.name
                    return StringModel.riak
                end
                @riak
            end

            def riak=(v)
                @riak = v
                unless @riak.nil?
                    ensure_search_index()
                end
                @riak
            end

            private

            def ensure_search_index()
                return unless respond_to_index_name?
                bucket = riak.with { |r|
                    r.create_search_index(index_name, '_yz_default')
                    r.bucket(namespace)
                }
                bucket.properties = { 'search_index' => index_name }
            end

            def respond_to_index_name?()
                @respond_to_index_name ||= respond_to?(:index_name)
            end
        end
        self.extend ConnectionMethods
    end
end
