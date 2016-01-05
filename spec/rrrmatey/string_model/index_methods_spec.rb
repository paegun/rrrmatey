require 'spec_helper'

class IndexModel
    extend RRRMatey::StringModel::IndexMethods

    class ConnPool
        def initialize(conn)
            @conn = conn
        end

        def with(&block)
            block.call(@conn)
        end
    end

    class Conn
        @@search_index_name =
            @@search_index_term =
            @@search_start =
            @@search_rows =
            @@search_sort = nil

        def search_index_name
            @@search_index_name
        end

        def search_index_term
            @@search_index_term
        end

        def search_start
            @@search_start
        end

        def search_rows
            @@search_rows
        end

        def search_sort
            @@search_sort
        end

        def self.mock_results(limit)
            item_name_prefix = "#{IndexModel.item_name}."
            {
                'num_found' => 3,
                'docs' => [
                    {
                        '_yz_rk' => 'di1',
                        "#{item_name_prefix}name" => 'eman1'
                    },
                    {
                        '_yz_rk' => 'di2',
                        "#{item_name_prefix}name" => 'eman2'
                    },
                    nil,
                    {
                        '_yz_rk' => 'di3',
                        "#{item_name_prefix}name" => 'eman3'
                    }
                ]
            }
        end

        def search(index_name, index_term, opts = {})
            @@search_index_name = index_name
            @@search_index_term = index_term
            @@search_start = opts[:start]
            @@search_rows = opts[:rows]
            @@search_sort = opts[:sort]

            self.class.mock_results(@@search_rows)
        end
    end

    def self.namespace()
        'index_models'
    end

    def self.item_name()
        'index_model'
    end

    def self.riak()
        @riak
    end

    def self.riak=(v)
        @riak = v
    end

    def self.object_from_hash(h, id, content_type)
    end
end

describe RRRMatey::StringModel::IndexMethods do
    context 'with or without riak setup' do
        context 'index_name set' do
            let(:model_klass) {
                IndexModel.index_name = 'something_else'
                IndexModel
            }

            describe '#index_name' do
                it 'yields values from self' do
                    expect(model_klass.index_name).to eq('something_else')
                end
            end
        end

        context 'index_name not set' do
            let(:model_klass) {
                IndexModel.index_name = nil
                IndexModel
            }
            let(:offset) { 4 }
            let(:limit) { 20 }
            let(:empty_discrete_result) {
                RRRMatey::DiscreteResult.new(:length => 0,
                                             :offset => offset,
                                             :discrete_length => limit,
                                             :results => [])
            }

            describe '#index_name' do
                it 'yields values from StringModel' do
                    expect(model_klass.index_name).to eq('index_models')
                end
            end

            describe '#list' do
                let(:list_result) { model_klass.list(offset, limit) }

                it 'yields an empty DiscreteResult' do
                    expect(list_result.length).to eq(empty_discrete_result.length)
                    expect(list_result.offset).to eq(empty_discrete_result.offset)
                    expect(list_result.discrete_length).to eq(empty_discrete_result.discrete_length)
                    expect(list_result.results).to eq(empty_discrete_result.results)
                end
            end

            describe '#list_by' do
                let(:list_by_result) { model_klass.list_by(offset, limit, :name => 'ema*') }

                it 'yields an empty DiscreteResult' do

                end
            end
        end
    end

    context 'with riak setup' do
        let(:riak) { IndexModel::Conn.new() }
        let(:riak_pool) { 
            IndexModel::ConnPool.new(riak)
        }
        let(:model_klass) {
            IndexModel.index_name = nil
            IndexModel.riak = riak_pool
            IndexModel
        }
        let(:offset) { 4 }
        let(:limit) { 20 }
        let(:results) { IndexModel::Conn.mock_results(limit) }
        let(:result_docs) { results['docs'].select { |it| !it.nil? } }
        let(:discrete_result) {
            RRRMatey::DiscreteResult.new(:length => results.length,
                                         :offset => offset,
                                         :discrete_length => limit,
                                         :results => results)
        }

        describe '#list' do
            let(:list_result) { model_klass.list(offset, limit) }

            it 'yields a hydrated DiscreteResult' do
                expect(list_result.length).to eq(result_docs.length)
            end

            it 'passes the index_name to riak search' do
                expect(riak.search_index_name).to eq(model_klass.index_name)
            end

            it 'passes the open index_term to riak search' do
                expect(riak.search_index_term).to eq('*:*')
            end

            it 'passes the offset to riak search' do
                expect(riak.search_start).to eq(offset)
            end

            it 'passes the limit to riak search' do
                expect(riak.search_rows).to eq(limit)
            end

            it 'passes riak key ascending sort to riak search' do
                expect(riak.search_sort).to eq('_yz_rk asc')
            end
        end

        describe '#list_by' do
            let(:list_result) { model_klass.list_by(offset, limit, :name => 'ema*',
                                                    :birth => Date.today) }
            let(:birth_date) { Date.today.to_s }

            it 'yields a hydrated DiscreteResult' do
                expect(list_result.length).to eq(result_docs.length)
            end

            it 'passes the index_name to riak search' do
                expect(riak.search_index_name).to eq(model_klass.index_name)
            end

            it 'passes the specified index_term to riak search' do
                expect(riak.search_index_term).to eq("index_model.name:ema* OR index_model.birth:#{birth_date}")
            end

            it 'passes the offset to riak search' do
                expect(riak.search_start).to eq(offset)
            end

            it 'passes the limit to riak search' do
                expect(riak.search_rows).to eq(limit)
            end

            it 'passes riak key ascending sort to riak search' do
                expect(riak.search_sort).to eq('_yz_rk asc')
            end
        end
    end
end
