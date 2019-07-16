ActiveAdmin.register Legislation do
  permit_params :title, :description, :framework, :location_id, :law_id

  filter :title
  filter :description
  filter :framework
  filter :location

  index do
    column :title do |legislation|
      link_to legislation.title, admin_legislation_path(legislation)
    end
    column :framework
    column :location
    column :slug

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :title
      f.input :description
      columns do
        column { f.input :location }
        column do
          f.input :framework,
                  as: :select,
                  collection: array_to_select_collection(Legislation::FRAMEWORKS)
        end
      end
    end

    f.actions
  end

  controller do
    def scoped_collection
      super.includes(:location)
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
