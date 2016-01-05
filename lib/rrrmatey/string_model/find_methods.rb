module RRRMatey
    module StringModel
        module FindMethods
            def get(id)
                return if id.blank? || self.cache_proxy.nil?
                s = nil
                self.cache_proxy.with { |r|
                    s = r.get(namespaced_key(id))
                }

                type = interpolate_type(s)
                h = typed_string_to_hash(s, type)
                o = object_from_hash(h, id, type)
                if o.content_type == 'application/unknown'
                    o.content_type = 'application/json'
                end
                o
            end

            private

            def interpolate_type(s)
                if s.blank? || s.start_with?('{') && s.end_with?('}')
                    :json
                elsif s.start_with?('<') && s.end_with?('>')
                    :xml
                else
                    :string
                end
            end

            def content_type_from_type(type)
                case type
                when :json
                    'application/json'
                when :xml
                    'application/xml'
                # NOTE: unreachable since typed_string_to_hash throws for unknown
                # else
                #     'application/unknown'
                end
            end

            def typed_string_to_hash(s, type)
                return {} if s.blank?
                case type
                when :json
                    JSON.parse(s)
                when :xml
                    Hash.from_xml(s)
                else
                    raise UnknownContentTypeError
                end
            rescue
                raise UnparseableContentError
            end

            def object_from_hash(h, id, type)
                o = new
                o.id = id
                o.content_type = content_type_from_type(type)

                h = h[self.item_name]
                if h.nil?
                    # ie, search result with extractor missing
                    o.content_type = 'application/unknown'
                else
                    consumer_fields.each do |f|
                        fs = f.to_s
                        if h.has_key?(fs)
                            o.send("#{f}=", h[fs])
                        end
                    end
                    fields.each do |f|
                        fs = f.to_s
                        if h.has_key?(fs)
                            o.send("#{f}=", h[fs])
                        end
                    end
                end
                o
            end
        end
    end
end
