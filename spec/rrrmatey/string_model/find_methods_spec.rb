require 'spec_helper'

class FindModel
    extend RRRMatey::StringModel::FindMethods

    @@cache_proxy = nil
    
    def self.cache_proxy
        @@cache_proxy
    end
    
    def self.cache_proxy=(v)
        @@cache_proxy = v
    end

    def self.item_name()
        'find_model'
    end

    def self.namespace
        'find_models'
    end

    def self.namespaced_key(id)
        "#{namespace}:#{id}"
    end

    attr_accessor :id, :content_type
    attr_accessor :name
    attr_accessor :field_dne_d

    def self.fields
        [ :name_s, :field_dne_d ]
    end

    def self.consumer_fields
        [ :name ]
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
        attr_accessor :result

        def get(id)
            @result
        end
    end
end

describe RRRMatey::StringModel::FindMethods do
    context 'with or without cache_proxy setup' do
        let(:model_klass) { FindModel }

        describe '#get' do
            it 'returns nil if cache_proxy is not set' do
                expect(model_klass.get('di')).to be(nil)
            end

            it 'returns nil if id is blank' do
                expect(model_klass.get(nil)).to be(nil)
            end
        end
    end

    context 'with cache_proxy setup' do
        let(:cache_proxy) { FindModel::Conn.new() }
        let(:model_klass) {
            m = FindModel
            m.cache_proxy = FindModel::ConnPool.new(cache_proxy)
            m
        }

        context 'with no value at key' do
            let(:model) { model_klass.get('di') }

            describe '#get' do
                it 'returns object with id and content-type set' do
                    expect(model.id).to eq('di')
                    expect(model.content_type).to eq('application/json')
                end
            end
        end

        context 'with json value at key' do
            let(:result) { '{"find_model":{"id":"di","name":"eman","field_dne_d":2.718}}' }
            let(:model) {
                m = model_klass
                cache_proxy.result = result
                m.get('di')
            }

            describe '#get' do
                it 'returns object with fields set' do
                    expect(model.id).to eq('di')
                    expect(model.content_type).to eq('application/json')
                    expect(model.name).to eq('eman')
                end
            end
        end

        context 'with xml value at key' do
            let(:result) { '<root><find_model><id>di</id><name>eman</name><field_dne_d>2.718</field_dne_d></find_model></root>' }
            let(:model) {
                m = model_klass
                cache_proxy.result = result
                m.get('di')
            }

            describe '#get' do
                it 'returns object with fields set' do
                    expect(model.id).to eq('di')
                    expect(model.content_type).to eq('application/xml')
                    expect(model.name).to eq('eman')
                end
            end
        end

        context 'with string value at key' do
            let(:result) { <<EOF
id:di
name:eman
field_dne_d:2.718
EOF
            }
            let(:model_klass_s) {
                m = model_klass
                cache_proxy.result = result
                m
            }

            describe '#get' do
                it 'raises UnparseableContentError' do
                    expect{model_klass_s.get('di')}.to raise_error(RRRMatey::UnparseableContentError)
                end
            end
        end
    end
end
