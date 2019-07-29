ActiveAdmin.register Target do
  menu parent: 'Laws', priority: 3

  permit_params :description, :sector_id, :location_id,
                :year, :type, :base_year_period, :ghg_target

  filter :type,
         as: :check_boxes,
         collection: proc { array_to_select_collection(Target::TYPES) }
  filter :ghg_target
  filter :sector

  config.batch_actions = false

  index do
    selectable_column
    column :location
    column :sector
    column :ghg_target
    column :year
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :type, as: :select, collection: array_to_select_collection(Target::TYPES)
      f.input :ghg_target
      f.input :year
      f.input :base_year_period
      f.input :location
      f.input :sector
      f.input :description, as: :trix
    end

    f.actions
  end
end
