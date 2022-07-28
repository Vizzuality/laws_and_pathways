ActiveAdmin.register TPISectorCluster do
  config.batch_actions = false
  config.sort_order = :name_asc

  decorate_with TPISectorClusterDecorator

  menu priority: 7, parent: 'TPI'

  permit_params :name

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
end
