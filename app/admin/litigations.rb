ActiveAdmin.register Litigation do
  menu parent: 'Laws', priority: 2

  decorate_with LitigationDecorator

  publishable_scopes
  publishable_resource_sidebar

  permit_params :title, :geography_id, :document_type, :jurisdiction,
                :visibility_status, :summary, :at_issue,
                :citation_reference_number, :created_by_id, :updated_by_id,
                :keywords_string, :responses_string,
                litigation_sides_attributes: permit_params_for(:litigation_sides),
                documents_attributes: permit_params_for(:documents),
                events_attributes: permit_params_for(:events),
                legislation_ids: [], external_legislation_ids: [],
                laws_sector_ids: []

  filter :id_equals, label: 'ID'
  filter :title_contains
  filter :created_at
  filter :updated_at
  filter :citation_reference_number_contains, label: 'Citation Reference Number'
  filter :summary_contains
  filter :geography
  filter :responses,
         as: :check_boxes,
         collection: proc { Response.all }
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
    column :id
    column :title, &:title_link
    column :geography
    column :document_type
    tag_column :visibility_status

    actions
  end

  csv do
    column :id
    column :title
    column :document_type
    column(:geography_iso) { |l| l.geography&.iso }
    column(:geography) { |l| l.geography&.name }
    column :jurisdiction
    column :citation_reference_number
    column :summary
    column(:sectors) { |l| l.laws_sectors.map(&:name).join(Rails.application.config.csv_options[:entity_sep]) }
    column :responses, &:responses_string
    column :keywords, &:keywords_string
    column :at_issue
    column(:visibility_status) { |l| l.visibility_status&.humanize }
    column(:legislation_ids) { |l| l.legislation_ids.join(Rails.application.config.csv_options[:entity_sep]) }
  end

  action_item :preview, priority: 0, only: :show do
    link_to 'Preview', resource.preview_url
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
          list_row 'Sectors', :laws_sector_links
          row :document_type
          row :citation_reference_number
          row :summary
          row :at_issue
          row 'Responses (e.g. adaptation or mitigation)', &:responses_string
          row 'Keywords', &:keywords_string
          list_row 'Documents', :document_links
          list_row 'Laws', :legislation_links
          list_row 'External Laws', :external_legislation_links
          row :updated_at
          row :updated_by
          row :created_at
          row :created_by
        end
      end

      tab :sides do
        panel 'Litigation Sides' do
          table_for resource.litigation_sides
            .includes(:connected_entity).decorate do
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

  can_batch_publish = proc { can?(:publish, Litigation) && current_scope&.name != 'Published' }
  can_batch_archive = proc { can?(:archive, Litigation) && current_scope&.name != 'Archived' }
  can_batch_destroy = proc { can?(:destroy, Litigation) }

  batch_action :publish, priority: 1, if: can_batch_publish do |ids|
    publish_command = ::Command::Batch::Publish.new(scoped_collection, ids)

    message = if publish_command.call.present?
                {notice: "Successfully published #{ids.count} Litigations"}
              else
                {alert: 'Could not publish selected Litigations'}
              end

    redirect_to collection_path(scope: 'published'), message
  end

  batch_action :archive, priority: 1, if: can_batch_archive do |ids|
    archive_command = ::Command::Batch::Archive.new(scoped_collection, ids)

    message = if archive_command.call.present?
                {notice: "Successfully archived #{ids.count} Litigations"}
              else
                {alert: 'Could not archive selected Litigations'}
              end

    redirect_to collection_path(scope: 'archived'), message
  end

  batch_action :destroy, if: can_batch_destroy do |ids|
    delete_command = Command::Batch::Delete.new(scoped_collection, ids)

    message = if delete_command.call.present?
                {notice: "Successfully deleted #{ids.count} Litigations"}
              else
                {alert: 'Could not delete selected Litigations'}
              end

    redirect_to collection_path, message
  end

  controller do
    include DiscardableController

    def scoped_collection
      super.includes(:geography, :laws_sectors, :responses,
                     :created_by, :updated_by)
    end

    def apply_filtering(chain)
      super(chain).distinct
    end
  end
end
