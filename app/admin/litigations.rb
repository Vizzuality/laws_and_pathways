ActiveAdmin.register Litigation do
  menu parent: 'Laws', priority: 2

  decorate_with LitigationDecorator

  publishable_scopes
  publishable_sidebar only: :show

  permit_params :title, :geography_id, :jurisdiction_id, :document_type,
                :visibility_status, :summary, :core_objective,
                :created_by_id, :updated_by_id, :keywords_string,
                litigation_sides_attributes: [
                  :id, :_destroy, :name, :side_type, :party_type, :connected_with
                ],
                documents_attributes: [
                  :id, :_destroy, :name, :language, :external_url, :type, :file
                ],
                events_attributes: [
                  :id, :_destroy, :title, :event_type, :description, :url, :date
                ],
                legislation_ids: []

  filter :title_contains
  filter :summary_contains
  filter :geography
  filter :document_type, as: :select, collection: proc {
    array_to_select_collection(Litigation::DOCUMENT_TYPES)
  }

  config.batch_actions = false

  index do
    column :title, class: 'max-width-300', &:title_link
    column :document_type
    column :geography
    column :citation_reference_number
    column :created_by
    column :updated_by
    tag_column :visibility_status

    actions
  end

  action_item :bulk_upload, only: :index do
    link_to 'Bulk Upload', new_admin_data_upload_path(data_upload: {uploader: 'Litigations'})
  end

  csv do
    column :id
    column :title
    column :document_type
    column(:geography_iso) { |l| l.geography.iso }
    column(:geography) { |l| l.geography.name }
    column(:jurisdiction_iso) { |l| l.jurisdiction.iso }
    column(:jurisdiction) { |l| l.jurisdiction.name }
    column :citation_reference_number
    column :summary
    column :keywords, &:keywords_string
    column :core_objective
    column(:visibility_status) { |l| l.visibility_status&.humanize }
    column(:legislation_ids) { |l| l.legislation_ids.join('; ') }
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :title
          row :slug
          row :geography
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

      tab :events do
        panel 'Litigation Events' do
          table_for resource.events.decorate do
            column :date
            column :event_type
            column :title
            column :description
            column 'URL', &:url_link
          end
        end
      end
    end
  end

  form partial: 'form'

  controller do
    def scoped_collection
      super.includes(:geography, :created_by, :updated_by)
    end
  end
end
