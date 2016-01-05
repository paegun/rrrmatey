require 'spec_helper'

class Conn
    def get(id)
        { :id => id }
    end
end

class ConnPool
    def initialize(opts = {})
        @conn = Conn.new()
        @errors = opts[:errors] || -1
    end

    def with(&block)
        if @errors > 0
            @errors -= 1
            raise "errors remaining: #{@errors}"
        else
            block.call(@conn)
        end
    end
end

describe RRRMatey::Retryable do
    describe '#initialize' do
        let(:conn) { Conn.new() }
        let(:conn_pool) { ConnPool.new() }
        let(:default) { RRRMatey::Retryable.new(conn) }
        let(:default_pool) { RRRMatey::Retryable.new(conn_pool) }
        let(:optioned) { RRRMatey::Retryable.new(conn_pool,
                                                 :retries => 5,
                                                 :retry_delay => 0.01) }

        it 'has sane defaults for conn_pool' do
            expect(default_pool.instance_variable_get(:@retries)).to eq(3)
            expect(default_pool.instance_variable_get(:@retry_delay)).to eq(0.1)
            expect(default_pool.instance_variable_get(:@conn)).to eq(conn_pool)
            expect(default_pool.instance_variable_get(:@conn_respond_to_with)).to be(true)
        end

        it 'has sane defaults for conn' do
            expect(default.instance_variable_get(:@retries)).to eq(3)
            expect(default.instance_variable_get(:@retry_delay)).to eq(0.1)
            expect(default.instance_variable_get(:@conn)).to eq(conn)
            expect(default.instance_variable_get(:@conn_respond_to_with)).to be(false)
        end

        it 'accepts options' do
            expect(optioned.instance_variable_get(:@retries)).to eq(5)
            expect(optioned.instance_variable_get(:@retry_delay)).to eq(0.01)
            expect(optioned.instance_variable_get(:@conn)).to eq(conn_pool)
            expect(optioned.instance_variable_get(:@conn_respond_to_with)).to be(true)
        end
    end

    describe '#with' do
        let(:conn) { Conn.new() }
        let(:conn_pool) { ConnPool.new() }
        let(:flappy_conn) { ConnPool.new(:errors => 2) }
        let(:failing_conn) { ConnPool.new(:errors => 10) }
        let(:optioned) { RRRMatey::Retryable.new(conn,
                                                 :retries => 5,
                                                 :retry_delay => 0.01) }
        let(:optioned_pool) { RRRMatey::Retryable.new(conn_pool,
                                                      :retries => 5,
                                                      :retry_delay => 0.01) }
        let(:flappy_optioned_pool) { RRRMatey::Retryable.new(flappy_conn,
                                                             :retries => 5,
                                                             :retry_delay => 0.01) }
        let(:failing_optioned_pool) { RRRMatey::Retryable.new(failing_conn,
                                                              :retries => 5,
                                                              :retry_delay => 0.01) }

        it 'yields nil if !block.given?' do
            expect(optioned.with()).to be(nil)
        end

        it 'yields block response on no error for conn' do
            expect(optioned.with { |c| c.get(3) }).to eq({:id => 3})
        end

        it 'yields block response on no error for conn_pool' do
            expect(optioned_pool.with { |c| c.get(3) }).to eq({:id => 3})
        end

        it 'yields block response for flappy pool' do
            expect(flappy_optioned_pool.with { |c| c.get(3) }).to eq({:id => 3})
        end

        it 'raises for failing pool' do
            expect{failing_optioned_pool.with { |c| c.get(3) }}.to raise_error(RuntimeError)
        end
   end
end
