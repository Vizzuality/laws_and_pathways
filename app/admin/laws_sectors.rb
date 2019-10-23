ActiveAdmin.register LawsSector do
  config.batch_actions = false

  menu parent: 'Laws', priority: 5

  permit_params :name

  filter :name_contains

  index do
    id_column
    column :name do |sector|
      link_to sector.name, admin_laws_sector_path(sector)
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
    end

    f.actions
  end
end
