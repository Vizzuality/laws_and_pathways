ActiveAdmin.register Target do
  menu parent: 'Laws', priority: 3

  decorate_with TargetDecorator

  publishable_scopes
  publishable_sidebar only: :show

  permit_params :description, :sector_id, :geography_id, :single_year, :target_scope_id,
                :year, :base_year_period, :ghg_target, :target_type,
                :visibility_status,
                :created_by_id, :updated_by_id,
                legislation_ids: []

  filter :ghg_target
  filter :sector
  filter :target_scope
  filter :target_type,
         as: :select,
         collection: proc { array_to_select_collection(Target::TYPES) }

  data_export_sidebar 'Targets'

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
      list_row 'Legislations', :legislation_links
      row :updated_at
      row :updated_by
      row :created_at
      row :created_by
    end
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :ghg_target
      f.input :single_year, hint: 'singe or multi year target'
      f.input :year
      f.input :base_year_period
      f.input :target_type,
              as: :select,
              collection: array_to_select_collection(Target::TYPES)
      f.input :geography
      f.input :sector
      f.input :target_scope
      f.input :legislation_ids,
              as: :selected_list,
              label: 'Connected Legislations',
              fields: [:title],
              display_name: :title,
              order: 'title_asc'
      f.input :description, as: :trix
      f.input :visibility_status, as: :select
    end

    f.actions
  end

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
end
