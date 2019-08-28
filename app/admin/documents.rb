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
      return super.includes(:documentable) unless params[:q].present?

      documentable_type = params[:q][:documentable_type_eq]
      documentable_query_params = params[:q][:documentable]
      return unless documentable_type.present? && documentable_query_params.present?

      # drop '.._eq' sufixes
      query_params_hash = documentable_query_params.to_enum.to_h.deep_transform_keys { |key| key.gsub(/_eq$/, '') }

      puts "- will filter related Legislations using: where(legislations: #{query_params_hash})"
      super
        .includes(documentable_type.underscore.to_sym)                      # :legislation
        .where(documentable_type.underscore.pluralize => query_params_hash) # legislations: {}
    end
  end
end
