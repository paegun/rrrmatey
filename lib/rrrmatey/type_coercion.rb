class String
    def to_fixnum_to_date
        to_i.to_date
    end

    unless respond_to?(:underscore)
        def underscore
            self.gsub(/::/, '/').
                gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
                gsub(/([a-z\d])([A-Z])/,'\1_\2').
                tr("- ", "_").
                downcase
        end
    end

    unless respond_to?(:pluralize)
        def pluralize
            self + "s"
        end
    end

    unless respond_to?(:constantize)
        def constantize
            Module.const_get(self)
        end
    end
end

class Hash
    unless respond_to?(:to_xml)
        def to_xml(opts = {})
            root_name = opts[:root] || 'root'
            self.keys.each { |k| self[k] = 'null' if self[k].nil? }
            XmlSimple.xml_out(self, :root_name => root_name)
        end
    end

    unless self.class.respond_to?(:from_xml)
        def self.from_xml(s, opts={})
            XmlSimple.xml_in(s, :force_array => false)
        end
    end
end

class Fixnum
    def to_date
        Time.at(self).to_datetime
    end
end

class DateTime
    def seconds_since_epoch
        to_time.to_i
    end
end

class Date
    def seconds_since_epoch
        to_date.to_time.to_i
    end
end
