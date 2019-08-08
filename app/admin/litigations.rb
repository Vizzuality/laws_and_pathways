ActiveAdmin.register Litigation do
  menu parent: 'Laws', priority: 2

  decorate_with LitigationDecorator

  publishable_scopes

  permit_params :title, :location_id, :jurisdiction_id, :document_type,
                :visibility_status, :summary, :core_objective,
                :created_by_id, :updated_by_id, :keywords_string,
                litigation_sides_attributes: [
                  :id, :_destroy, :name, :side_type, :party_type, :connected_with
                ],
                documents_attributes: [
                  :id, :_destroy, :name, :external_url, :type, :file
                ],
                legislation_ids: []

  filter :title_contains
  filter :summary_contains
  filter :location
  filter :document_type, as: :select, collection: proc {
    array_to_select_collection(Litigation::DOCUMENT_TYPES)
  }

  config.batch_actions = false

  index do
    column :title, class: 'max-width-300', &:title_link
    column :document_type
    column :location
    column :citation_reference_number
    column :created_by
    column :updated_by
    tag_column :visibility_status

    actions
  end

  sidebar 'Publishing Status', only: :show do
    attributes_table do
      tag_row :visibility_status, interactive: true
    end
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :title
          row :slug
          row :location
          row :jurisdiction
          row :document_type
          row :citation_reference_number
          row :summary
          row :core_objective
          row 'Keywords', &:keywords_string
          row :updated_at
          row :updated_by
          row :created_at
          row :created_by
          list_row 'Documents', :document_links
          list_row 'Legislations', :legislation_links
        end
      end

      tab :sides do
        panel 'Litigation Sides' do
          table_for resource.litigation_sides.decorate do
            column :side_type
            column :name
            column :party_type
          end
        end
      end
    end
  end

  form partial: 'form'

  controller do
    def scoped_collection
      super.includes(:location, :created_by, :updated_by)
    end
  end
end
