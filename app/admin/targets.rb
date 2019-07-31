ActiveAdmin.register Target do
  menu parent: 'Laws', priority: 3

  decorate_with TargetDecorator

  permit_params :description, :sector_id, :location_id, :single_year, :target_scope_id,
                :year, :base_year_period, :ghg_target,
                target_type_ids: [], legislation_ids: []

  filter :ghg_target
  filter :sector
  filter :target_scope
  filter :target_types,
         as: :check_boxes,
         collection: proc { TargetType.all }

  config.batch_actions = false

  index do
    id_column
    column :location
    column :sector
    column :target_scope
    column :single_year
    column :ghg_target
    column :year
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
      row :target_types
      row :description
      row :location
      list_row 'Legislations', :legislation_links
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :ghg_target
      f.input :single_year, hint: 'singe or multi year target'
      f.input :year
      f.input :base_year_period
      f.input :target_type_ids,
              label: 'Target Types',
              as: :tags,
              collection: TargetType.all
      f.input :location
      f.input :sector
      f.input :target_scope
      f.input :legislation_ids,
              as: :selected_list,
              label: 'Connected Legislations',
              fields: [:title],
              display_name: :title,
              order: 'title_asc'
      f.input :description, as: :trix
    end

    f.actions
  end
end
