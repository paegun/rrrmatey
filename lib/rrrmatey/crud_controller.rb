module RRRMatey
    module CrudController
        def self.included(base)
            base.extend(ModelMethods)
        end

        module ModelMethods
            def model(*model_klass_n_stuff)
                if model_klass_n_stuff.blank?
                    model_klass
                else
                    @model_klass = model_klass_n_stuff[0]
                end
            end

            def model_klass
                @model_klass ||= opinionated_model
            end

            private

            def opinionated_model
                # remove sController from Controller klass name
                self.name[0..-12].constantize
            end
        end

        def index
            offset = params[:offset] || 0
            limit = params[:limit] || 20
            items = self.class.model_klass.list(offset, limit)
            respond_ok(items)
        end

        def show
            id = params[:id]
            if id.blank?
                return respond_bad_request
            end
            item = self.class.model_klass.get(id)
            if item.nil?
                return respond_not_found
            end
            respond_ok(item)
        end

        def destroy
            id = params[:id]
            if id.blank?
                return respond_bad_request
            end
            self.class.model_klass.delete(id)
            respond_ok(nil)
        end

        def update
            # TODO: get and merge with params if a patch-y update is desired
            item = self.class.model_klass.from_params(params)
            begin
                item.save
            rescue RRRMatey::InvalidModelError
                return respond_bad_request
            rescue StandardError => e
                return respond_internal_server_error(e)
            end
            respond_ok(nil)
        end

        def respond_bad_request
            respond_to do |format|
                format.json { render :json => nil, :status => 400 }
                format.xml { render :xml => nil, :status => 400 }
            end
        end

        def respond_not_found
            respond_to do |format|
                format.json { render :json => 'Not Found', :status => 404 }
                format.xml { render :xml => 'Not Found', :status => 404 }
            end
        end

        def respond_internal_server_error(e)
            respond_to do |format|
                format.json { render :json => { :mesage => e.message }, :status => 500 }
                format.xml { render :xml => { :message => e.message }, :status => 500 }
            end
        end

        def respond_ok(item)
            respond_to do |format|
                format.json { render :json => item }
                format.xml { render :xml => item  }
            end
        end
    end
end
