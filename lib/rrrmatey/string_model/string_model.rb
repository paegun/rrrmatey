module RRRMatey
    module StringModel
        require 'json'
        require 'xmlsimple'
        require_relative 'connection_methods'
        require_relative 'namespaced_key_methods'
        require_relative 'field_definition_methods'
        require_relative 'index_methods'
        require_relative 'find_methods'
        require_relative 'delete_methods'
        require_relative 'consumer_adapter_methods'

        def self.included(base)
            base.extend ConnectionMethods
            base.extend NamespacedKeyMethods
            base.extend FieldDefinitionMethods
            base.extend IndexMethods
            base.extend FindMethods
            base.extend DeleteMethods
            base.extend ConsumerAdapterMethods
        end

        self.extend ConnectionMethods

        attr_accessor :content_type, :id
        def content_type()
            @content_type || 'application/json'
        end

        def save()
            raise UnsupportedTypeError.new(content_type) if content_type == 'application/unknown'
            raise InvalidModelError if id.blank?
            raise InvalidModelError if has_valid? && !valid?
            h = to_hash()
            s = hash_to_typed_string(h)
            unless self.class.cache_proxy.nil?
                self.class.cache_proxy.with { |r|
                    r.set(self.class.namespaced_key(id), s)
                }
            end
            self
        end

        def delete()
            self.class.delete(id)
        end

        def to_json(opts = {})
            to_consumer_hash.to_json
        end

        def to_xml(opts = {})
            to_consumer_hash.to_xml(:root => self.class.item_name)
        end

        private

        def to_consumer_hash
            h = {
                'id' => id
            }
            self.class.consumer_fields.each do |f|
                h[f] = send(f.to_sym)
            end
            h
        end

        def has_valid?
            @has_valid ||= respond_to?(:valid?)
        end

        def to_hash()
            h = {}
            unless self.class.fields.nil?
                self.class.fields.each {|f| h[f.to_s] = send(f) }
            end
            h
        end

        def hash_to_typed_string(h)
            case content_type
            when 'application/json'
                { self.class.item_name => h }.to_json
            when 'application/xml'
                h.to_xml(:root => self.class.item_name, :skip_instruct => true,
                         :indent => 0)
            else
                raise UnknownContentTypeError
            end
        end
    end
end
