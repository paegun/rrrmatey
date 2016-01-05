require 'spec_helper'

class StringModelKlass
    include RRRMatey::StringModel

    field :name, :type => :string

    attr_accessor :valid

    def initialize(opts = {})
        @valid = opts[:valid] || true
    end

    def valid?
        @valid
    end

    class ConnPool
        def initialize(conn)
            @conn = conn
        end

        def with(&block)
            block.call(@conn)
        end
    end

    class Conn
        attr_reader :search_index, :schema, :bucket_name, :kvs

        def initialize(opts = {})
            @kvs = opts[:kvs] || {}
        end

        def create_search_index(name, schema)
            @search_index = name
            @schema = schema
            nil
        end

        def bucket(name)
            RiakBucket.new(:name => name)
        end

        def set(k, v)
            @kvs[k] = v
        end

        def get(k)
            @kvs[k]
        end

        def del(k)
            (@kvs.delete(k).nil?) ? 0 : 1
        end
    end

    class RiakBucket
        attr_accessor :name, :properties

        def initialize(opts = {})
            @name = opts[:name]
        end
    end
end

describe RRRMatey::StringModel do
    context 'with or without riak setup' do
        let(:model_modyule) { RRRMatey::StringModel }
        let(:model_klass) { StringModelKlass }
        let(:model) { model_klass.new }

        describe '#extend' do
            it 'extends ConnectionMethods' do
                expect(extends_all_instance_methods(model_modyule, RRRMatey::StringModel::ConnectionMethods)).to eq(true)
            end
        end

        describe '#included' do
            it 'included extends ConnectionMethods' do
                expect(extends_all_instance_methods(model_klass, RRRMatey::StringModel::ConnectionMethods)).to eq(true)
            end

            it 'included extends NamespacedKeyMethods' do
                expect(extends_all_instance_methods(model_klass, RRRMatey::StringModel::NamespacedKeyMethods)).to eq(true)
            end

            it 'included extends FieldDefinitionMethods' do
                expect(extends_all_instance_methods(model_klass, RRRMatey::StringModel::FieldDefinitionMethods)).to eq(true)
            end

            it 'included extends IndexMethods' do
                expect(extends_all_instance_methods(model_klass, RRRMatey::StringModel::IndexMethods)).to eq(true)
            end

            it 'included extends FindMethods' do
                expect(extends_all_instance_methods(model_klass, RRRMatey::StringModel::FindMethods)).to eq(true)
            end

            it 'included extends DeleteMethods' do
                expect(extends_all_instance_methods(model_klass, RRRMatey::StringModel::DeleteMethods)).to eq(true)
            end

            it 'included extends ConsumerAdapterMethods' do
                expect(extends_all_instance_methods(model_klass, RRRMatey::StringModel::ConsumerAdapterMethods)).to eq(true)
            end
        end

        describe '#content_type' do
            it 'defaults to json' do
                expect(model.content_type).to eq('application/json')
            end
        end

        describe '#save' do
            it 'raises for unknown content' do
                model.content_type = 'application/unknown'
                expect{model.save()}.to raise_exception(RRRMatey::UnsupportedTypeError)
            end

            it 'raises for id.blank?' do
                model.content_type = 'application/json'
                model.id = nil
                expect{model.save()}.to raise_exception(RRRMatey::InvalidModelError)
            end

            it 'raises for invalid' do
                model.content_type = 'application/json'
                model.id = 'id'
                model.valid = false
                expect{model.save()}.to raise_exception(RRRMatey::InvalidModelError)
            end
        end

        describe '#delete' do
            it 'deletes' do
                expect(model.delete()).to eq(0)
            end
        end

        describe '#to_json' do
            it 'yields valid json when unset' do
                expect(model.to_json()).to eq('{"id":null,"name":""}')
            end

            it 'yields valid json when uet' do
                model.id = 'di'
                model.name = 'eman'
                expect(model.to_json()).to eq('{"id":"di","name":"eman"}')
            end
        end

        describe '#to_xml' do
            it 'yields valid xml when unset' do
                expect(model.to_xml()).to eq('<string_model_klass id="null" name="" />' + "\n")
            end

            it 'yields valid xml when uet' do
                model.id = 'di'
                model.name = 'eman'
                expect(model.to_xml()).to eq('<string_model_klass id="di" name="eman" />' + "\n")
            end
        end
    end

    context 'with connections setup' do
        let(:model) {
            m = StringModelKlass.new()
            m.class.riak = StringModelKlass::ConnPool.new(StringModelKlass::Conn.new)
            m.class.cache_proxy = StringModelKlass::ConnPool.new(StringModelKlass::Conn.new)
            m.content_type = 'application/json'
            m.id = 'id'
            m.valid = true
            m
        }

        describe '#save' do
            it 'saves for valid' do
                expect(model.save()).to eq(model)
            end

            it 'saves for valid xml' do
                model.content_type = 'application/xml'
                expect(model.save()).to eq(model)
            end

            it 'raises for unsupported content type' do
                model.content_type = 'application/protobuf'
                expect{model.save()}.to raise_exception(RRRMatey::UnknownContentTypeError)
            end
        end

        describe '#delete' do
            it 'deletes' do
                expect(model.delete()).to eq(0)
            end
        end
    end
end

def extends_all_instance_methods(instance, modyule)
    extends_methods(instance, modyule.instance_methods)
end

def extends_methods(it, methods)
    return false if it.nil?
    (methods - it.methods).length == 0
end
