require 'spec_helper'

class Model
    attr_accessor :id, :content_type
    attr_accessor :name
    attr_accessor :name_s

    def initialize(opts = {})
        opts.each {|k,v| send("#{k}=".to_sym, v) }
    end

    def self.list(offset = 0, limit = 20)
        results = offset.upto(offset + limit - 1).map do |i|
            factory_by_i(i)
        end
        RRRMatey::DiscreteResult.new(:results => results,
                                     :length => 420,
                                     :offset => offset,
                                     :discrete_length => limit)
    end
    
    def self.get(id)
        return if id == 'dne'
        factory_by_id(id, "enam")
    end

    def self.delete(id)
        return 0 if id.nil?
        1
    end

    private

    def self.factory_by_i(i)
        factory_by_id("di#{i}", "#eman#{i}")
    end

    def self.factory_by_id(id, name)
        Model.new(:id => id, :name => name)
    end
end

class ModelsController
    include RRRMatey::CrudController

    attr_accessor :params

    # override respond_ methods to make testable
    def respond_bad_request
        { :status => 400, :content_type => 'application/json', :body => nil }
    end

    def respond_not_found
        { :status => 404, :content_type => 'application/json', :body => nil }
    end

    def respond_internal_server_error(e)
        { :status => 400, :content_type => 'application/json', :body => { :message => e.message } }
    end

    def respond_ok(item)
        { :status => 200, :content_type => 'application/json', :body => item }
    end
end

describe RRRMatey::CrudController do
    let(:kontroller_modyule) { RRRMatey::CrudController }
    let(:kontroller_klass) { ModelsController }
    let(:kontroller) { kontroller_klass.new }

    describe '#included' do
        it 'included extends ModelMethods' do
            expect(extends_all_instance_methods(kontroller_klass, RRRMatey::CrudController::ModelMethods)).to eq(true)
        end
    end

    describe '#index' do
        let(:params) { { :offset => 40, :limit => 2 } }
        let(:kontroller) {
            k = kontroller_klass.new
            k.params = params
            k
        }
        let(:response) {
            kontroller.index()
        }
        let(:status) { response[:status] }
        let(:content_type) { response[:content_type] }
        let(:body) { response[:body] }

        it 'responds with an :ok status' do
            expect(status).to eq(200)
        end

        it 'responds with a json content_type' do
            expect(content_type).to eq('application/json')
        end

        it 'responds with the specifid offset' do
            expect(body.offset).to eq(40)
        end

        it 'responds with the specifid limit' do
            expect(body.discrete_length).to eq(2)
        end

        it 'responds with the underlying length' do
            expect(body.length).to eq(420)
        end

        it 'lists the first page of model results' do
            expect(body.results.length).to eq(2)
        end
    end

    describe '#show' do
        context 'item found in store' do
            let(:params) { { :id => 'di2' } }
            let(:kontroller) {
                k = kontroller_klass.new
                k.params = params
                k
            }
            let(:response) {
                kontroller.show()
            }
            let(:status) { response[:status] }
            let(:content_type) { response[:content_type] }
            let(:body) { response[:body] }

            it 'responds with an :ok status' do
                expect(status).to eq(200)
            end

            it 'responds with a json content_type' do
                expect(content_type).to eq('application/json')
            end

            it 'responds with a model item' do
                expect(body.class.name).to eq('Model')
            end
        end

        context 'item not found in store' do
            let(:params) { { :id => 'dne' } }
            let(:kontroller) {
                k = kontroller_klass.new
                k.params = params
                k
            }
            let(:response) {
                kontroller.show()
            }
            let(:status) { response[:status] }
            let(:content_type) { response[:content_type] }
            let(:body) { response[:body] }

            it 'responds with an :ok status' do
                expect(status).to eq(404)
            end

            it 'responds with a json content_type' do
                expect(content_type).to eq('application/json')
            end

            it 'responds with a nil body' do
                expect(body).to be(nil)
            end
        end

        context 'id not specified' do
            let(:params) { { } }
            let(:kontroller) {
                k = kontroller_klass.new
                k.params = params
                k
            }
            let(:response) {
                kontroller.show()
            }
            let(:status) { response[:status] }
            let(:content_type) { response[:content_type] }
            let(:body) { response[:body] }

            it 'responds with an :ok status' do
                expect(status).to eq(400)
            end

            it 'responds with a json content_type' do
                expect(content_type).to eq('application/json')
            end

            it 'responds with a model item' do
                expect(body).to be(nil)
            end
        end

    end

    describe '#destroy' do
        context 'id specified' do
            let(:params) { { :id => 'di2' } }
            let(:kontroller) {
                k = kontroller_klass.new
                k.params = params
                k
            }
            let(:response) {
                kontroller.destroy()
            }
            let(:status) { response[:status] }
            let(:content_type) { response[:content_type] }
            let(:body) { response[:body] }

            it 'responds with an :ok status' do
                expect(status).to eq(200)
            end

            it 'responds with a json content_type' do
                expect(content_type).to eq('application/json')
            end

            it 'responds with an empty body' do
                expect(body).to be(nil)
            end
        end

        context 'id not specified' do
            let(:params) { { } }
            let(:kontroller) {
                k = kontroller_klass.new
                k.params = params
                k
            }
            let(:response) {
                kontroller.destroy()
            }
            let(:status) { response[:status] }
            let(:content_type) { response[:content_type] }
            let(:body) { response[:body] }

            it 'responds with an :ok status' do
                expect(status).to eq(400)
            end

            it 'responds with a json content_type' do
                expect(content_type).to eq('application/json')
            end

            it 'responds with a model item' do
                expect(body).to be(nil)
            end
        end
    end

    describe '#update' do
    end
end
