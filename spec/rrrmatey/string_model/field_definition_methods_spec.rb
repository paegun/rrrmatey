require 'spec_helper'

class SomeFieldyModel
    extend RRRMatey::StringModel::FieldDefinitionMethods

    field :name, :type => :string
    field :hornery, :type => :boolean
    field :created, :type => :date
    field :bounties, :type => :integer
    field :ales, :type => :long
    field :chins, :type => :double
    field :corks, :type => :float
end

describe RRRMatey::StringModel::FieldDefinitionMethods do
    let(:model_klass) { SomeFieldyModel }
    let(:model) { SomeFieldyModel.new }

    describe '#fields' do
        it 'yields fields defined on the model' do
            expect(model_klass.fields).to eq([:name_s, :hornery_b, :created_ti, :bounties_i, :ales_l, :chins_d, :corks_f])
        end

        it 'creates accessors for defined fields' do
            expect(model.respond_to?(:name)).to be(true)
            expect(model.respond_to?(:name=)).to be(true)
        end

        it 'allows fields to be defined programmatically' do
            model_klass.fields(:name, :birth)
            expect(model_klass.fields).to eq([:name, :birth])
        end

        it 'specializes initialize, mapping all opts set to field set ops' do
            expect(model_klass.new(:name => 'eman').name).to eq('eman')
        end
    end

    describe '#consumer_fields' do
        it 'yields consumer fields' do
            model_klass.fields(:name_s, :hornery_b, :created_ti, :bounties_i, :ales_l, :chins_d, :corks_f)
            expect(model_klass.consumer_fields).to eq([:name, :hornery, :created, :bounties, :ales, :chins, :corks])
        end
    end

    describe '#append_type' do
        it 'raises for unsupported type' do
            expect{model_klass.send(:append_type, :some_field, :some_unknown_type)}.to raise_error(RRRMatey::UnsupportedTypeError)
        end
    end
end
