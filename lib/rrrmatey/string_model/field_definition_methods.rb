module RRRMatey
    module StringModel
        module FieldDefinitionMethods
            def fields(*field_syms)
                if field_syms.blank?
                    @fields
                else
                    @fields =
                        field_syms.each { |field_sym| attr_accessor field_sym }

                    define_method('initialize') do |opts={}|
                        opts.each do |k,v|
                            send("#{k}=", v)
                        end
                    end
                end
            end

            def consumer_fields
                @consumer_fields || []
            end

            def field(field_sym, opts = {})
                fs = @fields || []
                type = opts[:type] || :string
                default = opts[:default]
                f = append_type(field_sym, type)
                
                cfs = self.consumer_fields
                cfs << field_sym
                @consumer_fields = cfs

                fs << f[:name]
                self.fields(*fs)

                define_method(field_sym) do
                    v = send(f[:name]) || default
                    v.send(f[:from_underlying])
                end
                define_method("#{field_sym}=") do |v|
                    v = v.send(f[:to_underlying] || :to_s)
                    send("#{f[:name]}=", v)
                end
                nil
            end

            private

            def append_type(field_sym, type)
                tms = type_mappings()
                unless tms.has_key?(type)
                    raise UnsupportedTypeError.new(field_sym)
                end
                tm = tms[type]
                tm[:name] = "#{field_sym}#{tm[:suffix]}".to_sym
                tm
            end

            def type_mappings()
                {
                    :string =>
                    {
                        :suffix => '_s',
                        :from_underlying => :to_s
                    },
                    :boolean =>
                    {
                        :suffix => '_b',
                        :from_underlying => :to_b
                    },
                    :date =>
                    {
                        :suffix => '_ti',
                        :from_underlying => :to_fixnum_to_date,
                        :to_underlying => :seconds_since_epoch
                    },
                    :integer =>
                    {
                        :suffix => '_i',
                        :from_underlying => :to_i
                    },
                    :long =>
                    {
                        :suffix => '_l',
                        :from_underlying => :to_i
                    },
                    :double =>
                    {
                        :suffix => '_d',
                        :from_underlying => :to_f
                    },
                    :float =>
                    {
                        :suffix => '_f',
                        :from_underlying => :to_f
                    }
                }
            end
        end
    end
end
