ActiveAdmin.register TPISectorCluster do
  config.batch_actions = false
  config.sort_order = :name_asc

  decorate_with TPISectorClusterDecorator

  menu priority: 8, parent: 'TPI'

  permit_params :name, sector_ids: []

  filter :name_contains

  show do
    attributes_table do
      row :id
      row :name
      list_row 'Sectors', &:sector_list
      row :created_at
      row :updated_at
    end
  end

  index do
    id_column
    column :name, &:name_link
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :sectors, as: :check_boxes, collection: TPISector.all.order(:name)
    end
    f.actions
  end
end
