require 'spec_helper'

class DiscreteModel
    attr_accessor :id, :name

    def initialize(opts = {})
        @id = opts[:id]
        @name = opts[:name]
    end

    def to_consumer_hash
        { 'id' => id, :name => name }
    end
end

describe RRRMatey::DiscreteResult do
    context 'empty results' do
        let(:results) { nil }
        let(:discrete_result) {
            RRRMatey::DiscreteResult.new(:results => results,
                                         :length => 42,
                                         :offset => 40,
                                         :discrete_length => 10)
        }

        describe '#initialize' do
            it 'sets results' do
                expect(discrete_result.results).to eq([])
            end

            it 'sets length' do
                expect(discrete_result.length).to eq(42)
            end

            it 'sets offset' do
                expect(discrete_result.offset).to eq(40)
            end

            it 'sets discrete_length' do
                expect(discrete_result.discrete_length).to eq(10)
            end
        end

        describe '#to_json' do
            it 'yields json array of results' do
                expect(discrete_result.to_json).to eq('{"length":42,"offset":40,"limit":10,"results":[]}')
            end
        end

        describe '#to_xml' do
            it 'yields xml array of results' do
                expect(discrete_result.to_xml.gsub(/\n/, '').
                       gsub(/\>\s+\</, '><')).
                       to eq('<root length="42" offset="40" limit="10"></root>')
            end
        end

    end

    context 'hydrated results' do
        let(:results) { [
            DiscreteModel.new(:id => 'di1', :name => 'name1'),
            DiscreteModel.new(:id => 'di2', :name => 'name2')
        ]}
        let(:discrete_result) {
            RRRMatey::DiscreteResult.new(:results => results,
                                         :length => 42,
                                         :offset => 40,
                                         :discrete_length => 10)
        }

        describe '#initialize' do
            it 'sets results' do
                expect(discrete_result.results).to eq(results)
            end

            it 'sets length' do
                expect(discrete_result.length).to eq(42)
            end

            it 'sets offset' do
                expect(discrete_result.offset).to eq(40)
            end

            it 'sets discrete_length' do
                expect(discrete_result.discrete_length).to eq(10)
            end
        end

        describe '#to_json' do
            it 'yields json array of results' do
                expect(discrete_result.to_json).to eq('{"length":42,"offset":40,"limit":10,"results":[{"id":"di1","name":"name1"},{"id":"di2","name":"name2"}]}')
            end
        end

        describe '#to_xml' do
            it 'yields xml array of results' do
                expect(discrete_result.to_xml.gsub(/\n/, '').
                       gsub(/\>\s+\</, '><')).
                       to eq('<root length="42" offset="40" limit="10"><results id="di1" name="name1" /><results id="di2" name="name2" /></root>')
            end
        end
    end
end
