module RRRMatey
    class PlankError < StandardError; end
    class UnknownContentTypeError < PlankError; end
    class UnparseableContentError < PlankError; end
    class InvalidModelError < PlankError; end
    class UnsupportedTypeError < PlankError
        def initialize(type)
            super("Unsupported type: #{type}")
        end
    end
end
