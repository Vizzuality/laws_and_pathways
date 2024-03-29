ActiveAdmin.register Document do
  config.batch_actions = false

  menu priority: 6

  decorate_with DocumentDecorator

  filter :name_contains
  filter :documentable_type, label: 'Attached to'
  filter :language,
         as: :select,
         collection: proc { all_languages_to_select_collection }

  data_export_sidebar 'Documents', upload: false

  actions :all, except: [:new, :edit, :create, :update]

  show do
    attributes_table do
      row :id
      row :name
      row :link, &:document_url_link
      row :language
      row :last_verified_on
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  index do
    column 'Name', &:document_page_link
    column 'Attached To', :documentable_type
    column 'Details', :documentable
    column :last_verified_on
    column :language
    actions
  end

  csv do
    column :id
    column :name
    column :url
    column :is_external, &:external?
    column :language
    column :last_verified_on
    column 'Documentable ID', &:documentable_id
    column :documentable_type
  end

  controller do
    def scoped_collection
      results = super.includes(:documentable).with_attached_file

      return results unless documentable_params

      results.where(documentable: documentable_scope)
    end

    private

    def documentable_scope
      find_documentable_klass&.ransack(documentable_params)&.result
    end

    def find_documentable_klass
      @documentable_klass ||= params.dig(:q, :documentable_type_eq)&.constantize
    rescue NameError => e
      raise "Can't find documentable class based on given 'documentable_type_eq' param: #{e.message}"
    end

    def documentable_params
      @documentable_params ||= params.dig(:q, :documentable)
    end
  end
end
