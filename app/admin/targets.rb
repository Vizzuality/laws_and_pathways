ActiveAdmin.register Target do
  menu parent: 'Laws', priority: 3

  decorate_with TargetDecorator

  publishable_scopes
  publishable_sidebar only: :show

  permit_params :description, :sector_id, :geography_id, :single_year, :target_scope_id,
                :year, :base_year_period, :ghg_target, :target_type,
                :visibility_status,
                :created_by_id, :updated_by_id,
                events_attributes: permit_params_for(:events),
                legislation_ids: []

  filter :ghg_target
  filter :sector
  filter :target_scope
  filter :target_type,
         as: :select,
         collection: proc { array_to_select_collection(Target::TYPES) }

  data_export_sidebar 'Targets', events: true

  index do
    selectable_column
    column(:description) { |target| link_to target.description, admin_target_path(target) }
    column :geography
    column :sector
    column :target_scope
    column :single_year
    column :ghg_target
    column :year
    column :created_by
    column :updated_by
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
          row :target_scope
          row :target_type
          row :description
          row :geography
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
    column(:geography) { |t| t.geography.name }
    column(:geography_iso) { |t| t.geography.iso }
    column(:sector) { |t| t.sector.name }
    column(:target_scope) { |t| t.target_scope.name }
    column :visibility_status
  end

  controller do
    include DiscardableController
  end
end
