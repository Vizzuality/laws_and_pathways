ActiveAdmin.register Legislation do
  config.sort_order = 'updated_at_desc'

  menu parent: 'Laws', priority: 1

  decorate_with LegislationDecorator

  publishable_scopes

  permit_params :title, :description, :parent_id,
                :geography_id, :law_id, :legislation_type,
                :created_by_id, :updated_by_id, :visibility_status,
                events_attributes: permit_params_for(:events),
                documents_attributes: permit_params_for(:documents),
                natural_hazard_ids: [], keyword_ids: [], response_ids: [],
                framework_ids: [], document_type_ids: [], instrument_ids: [],
                governance_ids: [], laws_sector_ids: []

  filter :id_equals, label: 'ID'
  filter :title_contains, label: 'Title'
  filter :description_contains, label: 'Description'
  filter :legislation_type,
         as: :select,
         collection: proc { array_to_select_collection(Legislation::LEGISLATION_TYPES) }
  filter :geography
  filter :created_at
  filter :updated_at
  filter :frameworks,
         as: :check_boxes,
         collection: proc { Framework.all }
  filter :responses,
         as: :check_boxes,
         collection: proc { Response.all }
  filter :visibility_status,
         as: :select,
         collection: proc { array_to_select_collection(VisibilityStatus::VISIBILITY) }

  index title: 'Laws and Policies' do
    selectable_column
    column :id
    column :title, &:title_summary_link
    column :geography
    column :legislation_type
    column :document_types
    column :frameworks
    tag_column :visibility_status

    actions
  end

  publishable_resource_sidebar

  data_export_sidebar 'Legislations', display_name: 'Laws', documents: true, events: true

  action_item :preview, priority: 0, only: :show do
    link_to 'Preview', resource.preview_url
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :title
          row :description
          row :geography
          row 'Parent legislation', &:parent
          list_row 'Sectors', :laws_sector_links
          row :law_id
          row :legislation_type
          row 'Frameworks', &:frameworks_string
          row 'Document Types', &:document_types_string
          row 'Responses (e.g. adaptation or mitigation)', &:responses_string
          row 'Natural Hazards', &:natural_hazards_string
          row 'Keywords', &:keywords_string
          list_row 'Targets', :target_links
          list_row 'Documents', :document_links
          list_row 'Instruments', :instrument_links
          list_row 'Governances', :governance_links
          row :updated_at
          row :updated_by
          row :created_at
          row :created_by
        end
      end

      eventable_tab 'Legislation Events'

      tab :litigations do
        panel 'Connected Litigations' do
          if resource.litigations.empty?
            div class: 'padding-20' do
              'No Litigations are connected with this legislation'
            end
          else
            table_for resource.litigations.decorate do
              column :title, &:title_link
              column :document_type
            end
          end
        end
      end
    end

    active_admin_comments
  end

  form partial: 'form'

  csv do
    column :id
    column :title
    column :link, &:preview_url
    column(:legislation_type) { |l| l.legislation_type.downcase }
    column :description
    column(:parent) { |l| l.parent&.title }
    column 'Parent Id', humanize_name: false, &:parent_id
    column(:geography) { |l| l.geography.name }
    column(:geography_iso) { |l| l.geography.iso }
    column(:sectors) { |l| l.laws_sectors.map(&:name).join(Rails.application.config.csv_options[:entity_sep]) }
    column :frameworks, &:frameworks_csv
    column :responses, &:responses_csv
    column :keywords, &:keywords_csv
    column :natural_hazards, &:natural_hazards_csv
    column :document_types, &:document_types_csv
    column :instruments, &:instruments_csv
    column :governances, &:governances_csv
    column(:litigation_ids) { |l| l.litigation_ids.join(Rails.application.config.csv_options[:entity_sep]) }
    column :visibility_status
  end

  can_batch_publish = proc { can?(:publish, Legislation) && current_scope&.name != 'Published' }
  can_batch_archive = proc { can?(:archive, Legislation) && current_scope&.name != 'Archived' }
  can_batch_destroy = proc { can?(:destroy, Legislation) }

  batch_action :publish, priority: 1, if: can_batch_publish do |ids|
    publish_command = ::Command::Batch::Publish.new(scoped_collection, ids)

    message = if publish_command.call.present?
                {notice: "Successfully published #{ids.count} Laws"}
              else
                {alert: 'Could not publish selected Laws'}
              end

    redirect_to collection_path(scope: 'published'), message
  end

  batch_action :archive, priority: 1, if: can_batch_archive do |ids|
    archive_command = ::Command::Batch::Archive.new(scoped_collection, ids)

    message = if archive_command.call.present?
                {notice: "Successfully archived #{ids.count} Laws"}
              else
                {alert: 'Could not archive selected Laws'}
              end

    redirect_to collection_path(scope: 'archived'), message
  end

  batch_action :destroy, if: can_batch_destroy do |ids|
    delete_command = Command::Batch::Delete.new(scoped_collection, ids)

    message = if delete_command.call.present?
                {notice: "Successfully deleted #{ids.count} Laws"}
              else
                {alert: 'Could not delete selected Laws'}
              end

    redirect_to collection_path, message
  end

  controller do
    include DiscardableController

    def scoped_collection
      super.includes(
        :geography,
        :frameworks,
        :document_types,
        :created_by,
        :updated_by,
        *csv_includes
      )
    end

    def csv_includes
      return [] unless csv_format?

      [
        :governances,
        :parent,
        :responses,
        :keywords,
        :natural_hazards,
        :laws_sectors,
        :litigations,
        instruments: [:instrument_type]
      ]
    end

    def csv_format?
      request[:format] == 'csv'
    end

    def apply_filtering(chain)
      super(chain).distinct
    end
  end
end
