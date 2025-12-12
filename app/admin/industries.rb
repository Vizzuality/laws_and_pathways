ActiveAdmin.register Industry do
  config.batch_actions = false
  config.sort_order = :name_asc

  decorate_with IndustryDecorator

  menu priority: 6, parent: 'TPI'

  permit_params :name, tpi_sector_ids: []

  filter :name_contains

  collection_action :download_example, method: :get do
    send_file Rails.root.join('industries_import_example.csv'),
              filename: 'industries_import_example.csv',
              type: 'text/csv',
              disposition: 'attachment'
  end

  action_item :bulk_upload, only: :index do
    link_to 'Bulk Upload CSV', new_admin_data_upload_path(uploader: 'Industries')
  end

  action_item :download_example, only: :index do
    link_to 'Download Example CSV', download_example_admin_industries_path
  end

  show do
    attributes_table do
      row :id
      row :name
      row :slug
      list_row 'Sectors', &:sector_list
      row :created_at
      row :updated_at
    end
  end

  index do
    id_column
    column :name, &:name_link
    column :slug
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :tpi_sectors, as: :check_boxes, collection: TPISector.all.order(:name)
    end
    f.actions
  end
end
