ActiveAdmin.register Event do
  menu false

  actions :index

  csv do
    column :id
    column :eventable_type
    column :eventable_id
    column :event_type
    column :title
    column :description
    column :date
    column :url
  end

  controller do
    def index
      super do |format|
        format.html { redirect_to admin_dashboard_path }
      end
    end

    def scoped_collection
      results = super.includes(:eventable)

      return results unless eventable_params

      results.where(eventable: eventable_scope)
    end

    private

    def eventable_scope
      find_eventable_klass&.ransack(eventable_params)&.result
    end

    def find_eventable_klass
      @eventable_klass ||= params.dig(:q, :eventable_type_eq)&.constantize
    rescue NameError => e
      raise "Can't find eventable class based on given 'eventable_type_eq' param: #{e.message}"
    end

    def eventable_params
      @eventable_params ||= params.dig(:q, :eventable)
    end
  end
end
