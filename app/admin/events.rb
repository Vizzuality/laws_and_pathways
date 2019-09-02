ActiveAdmin.register Event do
  menu label: 'All Events', priority: 3, parent: 'Administration'

  actions :all, except: [:new, :edit, :update, :show, :destroy]

  INDEX_COLUMNS_DEFINITION = proc do
    column :id
    column :eventable_type
    column :eventable_id
    column :event_type
    column :title
    column :description
    column :date
    column :url
  end

  index { instance_exec(&INDEX_COLUMNS_DEFINITION) }

  csv { instance_exec(&INDEX_COLUMNS_DEFINITION) }

  controller do
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
