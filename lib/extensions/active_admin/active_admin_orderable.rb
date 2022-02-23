module ActiveAdminOrderable
  module ControllerActions
    def orderable
      member_action :sort, method: :post do
        resource.insert_at params[:position].to_i
        head 200
      end
    end
  end

  module TableMethods
    def orderable_handle_column(options = {})
      column options.fetch(:name, ''), class: 'activeadmin-orderable' do |resource|
        sort_url = if options[:url].is_a? Symbol
                     send options[:url], resource
                   elsif options[:url].respond_to? :call
                     options[:url].call resource
                   else
                     sort_url, query_params = resource_path(resource).split '?', 2
                     sort_url += '/sort'
                     sort_url += '?' + query_params if query_params
                     sort_url
                   end
        content_tag :span, '', :class => 'handle', 'data-sort-url' => sort_url
      end
    end
  end
end
