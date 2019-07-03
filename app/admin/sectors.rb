ActiveAdmin.register Sector do
  permit_params :name

  filter :name_contains

  config.batch_actions = false

  index do
    column :name do |sector|
      link_to sector.name, admin_sector_path(sector)
    end
    column :slug
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
    end

    f.actions
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
