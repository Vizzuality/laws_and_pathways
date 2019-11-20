ActiveAdmin.register Litigation do
  menu parent: 'Laws', priority: 2

  decorate_with LitigationDecorator

  publishable_scopes
  publishable_sidebar only: :show

  permit_params :title, :jurisdiction_id, :sector_id, :document_type,
                :visibility_status, :summary, :at_issue,
                :citation_reference_number,
                :created_by_id, :updated_by_id, :keywords_string,
                litigation_sides_attributes: permit_params_for(:litigation_sides),
                documents_attributes: permit_params_for(:documents),
                events_attributes: permit_params_for(:events),
                legislation_ids: [], framework_ids: [],
                external_legislation_ids: []

  filter :title_contains
  filter :summary_contains
  filter :jurisdiction
  filter :frameworks,
         as: :check_boxes,
         collection: proc { Framework.all }
  filter :document_type, as: :select, collection: proc {
    array_to_select_collection(Litigation::DOCUMENT_TYPES)
  }

  data_export_sidebar 'Litigations', documents: true, events: true do
    li do
      link_to 'Download related Litigation Sides CSV', admin_litigation_sides_path(
        format: 'csv',
        q: {
          litigation: request.query_parameters[:q]
        }
      )
    end

    li do
      upload_label = '<strong>Upload</strong> Litigation Sides'.html_safe
      upload_path = new_admin_data_upload_path(data_upload: {uploader: 'LitigationSides'})

      link_to upload_label, upload_path
    end
  end

  index do
    selectable_column
    column :title, class: 'max-width-300', &:title_link
    column :document_type
    column :jurisdiction
    column :sector
    column 'Frameworks', &:frameworks_string
    column :citation_reference_number
    column :created_by
    column :updated_by
    tag_column :visibility_status

    actions
  end

  csv do
    column :id
    column :title
    column :document_type
    column(:jurisdiction_iso) { |l| l.jurisdiction.iso }
    column(:jurisdiction) { |l| l.jurisdiction.name }
    column(:sector) { |l| l.sector&.name }
    column :citation_reference_number
    column :summary
    column :frameworks, &:frameworks_string
    column :keywords, &:keywords_string
    column :at_issue
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
          row :jurisdiction
          row :sector
          row :document_type
          row :citation_reference_number
          row :summary
          row :at_issue
          row 'Frameworks', &:frameworks_string
          row 'Keywords', &:keywords_string
          row :updated_at
          row :updated_by
          row :created_at
          row :created_by
          list_row 'Documents', :document_links
          list_row 'Laws', :legislation_links
          list_row 'External Laws', :external_legislation_links
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

      eventable_tab 'Litigation Events'
    end

    active_admin_comments
  end

  form partial: 'form'

  batch_action :publish,
               priority: 1,
               if: proc { current_scope&.name != 'Published' } do |ids|
    publish_command = ::Command::Batch::Publish.new(batch_action_collection, ids)

    message = if publish_command.call
                {notice: "Successfully published #{ids.count} Litigations"}
              else
                {alert: 'Could not publish selected Litigations'}
              end

    redirect_to collection_path(scope: 'published'), message
  end

  batch_action :archive,
               priority: 1,
               if: proc { current_scope&.name != 'Archived' } do |ids|
    archive_command = ::Command::Batch::Archive.new(batch_action_collection, ids)

    message = if archive_command.call
                {notice: "Successfully archived #{ids.count} Litigations"}
              else
                {alert: 'Could not archive selected Litigations'}
              end

    redirect_to collection_path(scope: 'archived'), message
  end

  batch_action :destroy do |ids|
    delete_command = Command::Batch::Delete.new(batch_action_collection, ids)

    message = if delete_command.call
                {notice: "Successfully deleted #{ids.count} Litigations"}
              else
                {alert: 'Could not delete selected Litigations'}
              end

    redirect_to collection_path, message
  end

  controller do
    include DiscardableController

    def scoped_collection
      super.includes(:jurisdiction, :sector, :created_by, :updated_by)
    end
  end
end
