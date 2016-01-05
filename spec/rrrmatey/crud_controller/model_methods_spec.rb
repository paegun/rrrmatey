require 'spec_helper'

class OtherModel
end

class Model
end

class ModelsController
    extend RRRMatey::CrudController::ModelMethods
end

describe RRRMatey::CrudController::ModelMethods do
    let(:kontroller_klass) { ModelsController }

    describe '#model' do
        it 'defaults to controller name derived model' do
            expect(kontroller_klass.model).to eq(Model)
        end

        it 'allows specification' do
            kontroller_klass.model(OtherModel)
            expect(kontroller_klass.model).to eq(OtherModel)
        end
    end
end
