require 'spec_helper'

class SomeModel
    extend RRRMatey::StringModel::ConsumerAdapterMethods

    attr_accessor :id, :name, :content_type

    def self.object_from_hash(h, id, content_type)
        sm = SomeModel.new()
        sm.id = id
        sm.content_type = content_type
        sm.name = h[:name] || name
        sm
    end
end

describe RRRMatey::StringModel::ConsumerAdapterMethods do
    describe '#from_params' do
        let(:model_klass) { SomeModel }
        let(:params) { { :id => 'di', :name => 'eman' } }
        let(:model_params_id_content_type) { SomeModel.from_params(params, 'dis', :xml) }
        let(:model_params_id) { SomeModel.from_params(params, 'dis') }
        let(:model_params) { SomeModel.from_params(params) }

        it 'yields a model from params hash, id, and content-type' do
            expect(model_params_id_content_type.name).to eq(params[:name])
            expect(model_params_id_content_type.id).to eq('dis')
            expect(model_params_id_content_type.content_type).to eq(:xml)
        end

        it 'yields a model from params hash and id' do
            expect(model_params_id.name).to eq(params[:name])
            expect(model_params_id.id).to eq('dis')
            expect(model_params_id.content_type).to eq(:json)
        end

        it 'yields a model from params hash' do
            expect(model_params.name).to eq(params[:name])
            expect(model_params.id).to eq(params[:id])
            expect(model_params.content_type).to eq(:json)
        end
    end
end
