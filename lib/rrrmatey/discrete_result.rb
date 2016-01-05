module RRRMatey
    class DiscreteResult
        attr_reader :offset, :discrete_length, :length, :results

        def initialize(opts = {})
            @results = opts[:results].to_a
            @length = opts[:length]
            @offset = opts[:offset]
            @discrete_length = opts[:discrete_length]
        end

        def to_json(opts = {})
            to_consumer_hash.to_json
        end

        def to_xml(opts = {})
            to_consumer_hash.to_xml
        end

        private

        def to_consumer_hash
            {
                :length => length,
                :offset => offset,
                :limit => discrete_length,
                :results => results.map { |it| it.send(:to_consumer_hash) }
            }
        end
    end
end
