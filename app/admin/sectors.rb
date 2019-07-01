ActiveAdmin.register Sector do
  permit_params :name

  filter :name_contains

  index do
    selectable_column
    column :name do |sector|
      link_to sector.name, admin_sector_path(sector)
    end
    column :slug
    actions
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
