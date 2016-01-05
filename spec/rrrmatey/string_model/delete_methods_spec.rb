require 'spec_helper'

describe RRRMatey::StringModel::DeleteMethods do
    context 'with or without cache_proxy setup' do
        describe '#delete' do
            let(:model) { StringModelKlass.new() }

            it 'yields 0 if cache_proxy is not setup' do
                model.id = 'di'
                expect(model.delete()).to eq(0)
            end
        end
    end

    context 'with cache_proxy setup' do
        describe '#delete' do
            let(:model_klass) { StringModelKlass }
            let(:model) {
                m = model_klass.new()
                m.class.cache_proxy = StringModelKlass::ConnPool.new(StringModelKlass::Conn.new)
                m.class.cache_proxy.with { |c| c.set(model_klass.namespaced_key('di'), 'exists') }
                m
            }

            it 'yields 0 if value was not in the store' do
                model.id = 'dne'
                expect(model.delete()).to eq(0)
            end

            it 'yields 1 if the value was in the store' do
                model.id = 'di'
                expect(model.delete()).to eq(1)
            end
        end
    end
end
