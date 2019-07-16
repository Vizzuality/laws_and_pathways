ActiveAdmin.register Litigation do
  menu priority: 3

  permit_params :title, :location_id

  filter :title_contains
  filter :location

  config.batch_actions = false

  index do
    column :title do |l|
      link_to l.title, admin_litigation_path(l)
    end
    column :document_type, &:humanize
    column :location
    column :citation_reference_number
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :title
      f.input :location
      f.input :document_type, as: :select, collection: Litigation::DOCUMENT_TYPES
      f.input :summary, as: :trix
      f.input :core_objective, as: :trix
    end

    f.actions
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
