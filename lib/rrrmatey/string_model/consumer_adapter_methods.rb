module RRRMatey
    module StringModel
        module ConsumerAdapterMethods
            def from_params(params, id = nil, content_type = nil)
                send(:object_from_hash, params, id || params[:id], content_type || :json)
            end
        end
    end
end
