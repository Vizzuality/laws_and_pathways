ActiveAdmin.register Document do
  config.batch_actions = false

  menu priority: 6

  decorate_with DocumentDecorator

  filter :name_contains
  filter :documentable_type, label: 'Attached to'
  filter :language,
         as: :select,
         collection: proc { all_languages_to_select_collection }

  data_export_sidebar 'Documents'

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
  end

  index do
    column 'Name', &:document_page_link
    column 'Attached To', :documentable
    column :last_verified_on
    column :language
    actions
  end

  controller do
    def scoped_collection
      results = super.includes(:documentable)

      documentable_type = params.dig(:q, :documentable_type_eq)
      documentable_query_params = params.dig(:q, :documentable)
      if documentable_query_params.present? && documentable_query_params.present?
        documentable_klass = documentable_type.constantize
        results = results.where(
          documentable: documentable_klass.ransack(documentable_query_params).result
        )
      end

      results
    end
  end
end
