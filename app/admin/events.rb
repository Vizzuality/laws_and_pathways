ActiveAdmin.register Event do
  menu priority: 7

  decorate_with EventDecorator

  filter :title_contains
  filter :eventable_type, label: 'Eventable type'
  filter :date

  actions :all, except: [:new, :create]

  data_export_sidebar 'Events'

  show do
    attributes_table do
      row :id
      row :title
      row :url, &:url_link
      row :description
      row :date
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :title
      f.input :description
      f.input :event_type, as: :select, collection: array_to_select_collection(f.object.event_types, :titleize)
      f.input :date
      f.input :url, as: :string
    end

    f.actions
  end

  index do
    selectable_column
    column :title, &:title_link
    column :eventable
    column :event_type
    column :date
    actions
  end

  csv do
    column :id
    column :eventable_type
    column 'Eventable Id', humanize_name: false, &:eventable_id
    column :eventable_name
    column :event_type
    column :title
    column :description
    column :date
    column :url
  end

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
