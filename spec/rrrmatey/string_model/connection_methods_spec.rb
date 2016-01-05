require 'spec_helper'

class ConnectionModel
    extend RRRMatey::StringModel::ConnectionMethods

    class ConnPool
        def initialize(conn)
            @conn = conn
        end

        def with(&block)
            block.call(@conn)
        end
    end

    class Conn
    end
end

describe RRRMatey::StringModel::ConnectionMethods do
    context 'with riak and cache_proxy setup' do
        let(:conn) {  ConnectionModel::ConnPool.new(ConnectionModel::Conn.new()) }
        let(:model_klass) {
            m = ConnectionModel
            m.riak = conn
            m.cache_proxy = conn
            m
        }

        describe '#cache_proxy' do
            it 'yields values from self' do
                expect(model_klass.cache_proxy).to eq(conn)
            end
        end

        describe '#riak' do
            it 'yields values from self' do
                expect(model_klass.riak).to eq(conn)
            end
        end
    end

    context 'with or without riak and cache_proxy setup' do
        let(:model_klass) {
            m = ConnectionModel
            m.riak = nil
            m.cache_proxy = nil
            m
        }
        let(:string_model_klass) { RRRMatey::StringModel }

        describe '#cache_proxy' do
            it 'yields values from StringModel' do
                expect(model_klass.cache_proxy).to eq(string_model_klass.cache_proxy)
            end
        end

        describe '#riak' do
            it 'yields values from StringModel' do
                expect(model_klass.riak).to eq(string_model_klass.riak)
            end
        end
    end
end
