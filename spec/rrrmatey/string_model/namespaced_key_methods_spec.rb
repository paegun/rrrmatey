require 'spec_helper'

class SomeModel
    extend RRRMatey::StringModel::NamespacedKeyMethods
end

describe RRRMatey::StringModel::NamespacedKeyMethods do
    let(:model_klass) { SomeModel }
    describe '#item_name' do
        it 'defaults to name underscored' do
            model_klass.item_name = nil
            expect(model_klass.item_name).to eq('some_model')
        end

        it 'allows specification' do
            model_klass.item_name = 'something_else'
            expect(model_klass.item_name).to eq('something_else')
        end
    end

    describe '#namespace' do
        it 'defaults to item_name pluralized' do
            model_klass.item_name = nil
            expect(model_klass.namespace).to eq('some_models')
        end
    end

    describe '#namespaced_key' do
        it 'yields namespace:id' do
            model_klass.item_name = nil
            expect(model_klass.namespaced_key('di')).to eq("some_models:di")
        end
    end
end
