module RRRMatey
    module StringModel
        module IndexMethods
            def index_name()
                @index_name ||= self.namespace
            end

            def index_name=(v)
                @index_name = v
            end

            def list(offset = 0, limit = 20)
                index_by_index_term('*:*', offset, limit)
            end

            def list_by(offset = 0, limit = 20, field_qs = {})
                index_term = field_qs_to_index_term(field_qs)
                index_by_index_term(index_term, offset, limit)
            end

            private

            def index_by_index_term(index_term, offset, limit)
                search_result = nil
                unless self.riak.nil?
                    self.riak.with { |r|
                        # for consistent result, sort by key
                        search_result = r.search(self.index_name,
                                                 index_term,
                                                 {:start => offset,
                                                     :rows => limit,
                                                     :sort => '_yz_rk asc'})
                    }
                end
                search_result_to_discrete_result(search_result, offset, limit)
            end

            def search_result_to_discrete_result(search_result, offset, limit)
                search_result = {} if search_result.nil?

                if search_result['docs'].blank?
                    results = []
                else
                    results = search_result['docs'].map { |h|
                        if h.nil?
                            nil
                        else
                            id = h['_yz_rk']
                            h = normalize_hash(h)
                            object_from_hash(h, id, :json)
                        end
                    }
                end
                DiscreteResult.new(:length => search_result['num_found'] || 0,
                                   :offset => offset,
                                   :discrete_length => limit,
                                   :results => results)
            end

            def item_name_prefix()
                @item_name_prefix ||= "#{self.item_name}."
            end

            def normalize_hash(h)
                h_norm = {}
                item_name_prefix_len = item_name_prefix.length
                h.each do |k,v|
                    if k.start_with?(item_name_prefix)
                        normalized_key = k[item_name_prefix_len..-1]
                        h_norm[normalized_key] = v
                    end
                end
                return {} if h_norm.length <= 0
                { self.item_name => h_norm }
            end

            def field_qs_to_index_term(field_qs)
                return "*:*" if field_qs.blank?
                field_qs.reduce("") do |q, (k, v)|
                    q_part = "#{item_name_prefix}#{k}:#{v}"
                    if q.blank?
                        q += q_part
                    else
                        q += " OR #{q_part}"
                    end
                end
            end
        end
    end
end
