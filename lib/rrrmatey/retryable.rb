module RRRMatey
    class Retryable
        def initialize(conn, opts = {})
            @retries = opts[:retries] || 3
            @retry_delay = opts[:retry_delay] || 0.1
            @conn = conn
            @conn_respond_to_with = conn.respond_to?(:with)
        end

        def with(&block)
            return unless block_given?
            ex = nil
            1.upto(@retries) do
                begin
                    if @conn_respond_to_with
                        return @conn.with { |conn| block.call(conn) }
                    else
                        return block.call(@conn)
                    end
                rescue StandardError => e
                    ex = e
                    sleep(@retry_delay)
                end
            end
            raise ex
        end
    end
end
