ActiveAdmin.register Target do
  menu parent: 'Laws', priority: 3

  decorate_with TargetDecorator

  publishable_scopes
  publishable_resource_sidebar

  permit_params :description, :sector_id, :geography_id, :single_year,
                :year, :base_year_period, :ghg_target, :target_type,
                :visibility_status, :scopes_string, :source,
                :created_by_id, :updated_by_id,
                events_attributes: permit_params_for(:events),
                legislation_ids: []

  filter :geography
  filter :ghg_target
  filter :sector
  filter :target_type,
         as: :select,
         collection: proc { array_to_select_collection(Target::TYPES) }
  filter :source,
         as: :select,
         collection: proc { array_to_select_collection(Target::SOURCES) }

  data_export_sidebar 'Targets', events: true

  index do
    selectable_column
    column(:description) { |target| link_to target.description, admin_target_path(target) }
    column :geography
    column :sector
    column :year
    tag_column :visibility_status

    actions
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :ghg_target
          row :single_year
          row :year
          row :base_year_period
          row :sector
          row :source
          row :target_type
          row :description
          row :geography
          row 'Scopes', &:scopes_string
          list_row 'Laws', :legislation_links
          row :updated_at
          row :updated_by
          row :created_at
          row :created_by
        end
      end

      eventable_tab 'Target Events'
    end

    active_admin_comments
  end

  form partial: 'form'

  csv do
    column :id
    column(:target_type) { |t| t.model.target_type }
    column :description
    column :ghg_target
    column :year
    column :base_year_period
    column :single_year
    column :source
    column(:geography) { |t| t.geography.name }
    column(:geography_iso) { |t| t.geography.iso }
    column(:sector) { |t| t.sector&.name }
    column(:connected_law_ids) { |t| t.legislation_ids.join(',') }
    column :scopes, &:scopes_string
    column :visibility_status
  end

  can_batch_publish = proc { can?(:publish, Target) && current_scope&.name != 'Published' }
  can_batch_archive = proc { can?(:archive, Target) && current_scope&.name != 'Archived' }
  can_batch_destroy = proc { can?(:destroy, Target) }

  batch_action :publish, priority: 1, if: can_batch_publish do |ids|
    publish_command = ::Command::Batch::Publish.new(scoped_collection, ids)

    message = if publish_command.call.present?
                {notice: "Successfully published #{ids.count} Targets"}
              else
                {alert: 'Could not publish selected Targets'}
              end

    redirect_to collection_path(scope: 'published'), message
  end

  batch_action :archive, priority: 1, if: can_batch_archive do |ids|
    archive_command = ::Command::Batch::Archive.new(scoped_collection, ids)

    message = if archive_command.call.present?
                {notice: "Successfully archived #{ids.count} Targets"}
              else
                {alert: 'Could not archive selected Targets'}
              end

    redirect_to collection_path(scope: 'archived'), message
  end

  batch_action :destroy, if: can_batch_destroy do |ids|
    delete_command = Command::Batch::Delete.new(scoped_collection, ids)

    message = if delete_command.call.present?
                {notice: "Successfully deleted #{ids.count} Targets"}
              else
                {alert: 'Could not delete selected Targets'}
              end

    redirect_to collection_path, message
  end

  controller do
    include DiscardableController

    def scoped_collection
      super.includes(
        :geography,
        :scopes,
        :sector
      )
    end
  end
end
