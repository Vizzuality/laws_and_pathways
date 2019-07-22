ActiveAdmin.register Legislation do
  decorate_with LegislationDecorator

  menu parent: 'Laws', priority: 1

  permit_params :title, :description, :framework, :location_id, :law_id

  filter :title_contains, label: 'Title'
  filter :description_contains, label: 'Description'
  filter :location
  filter :framework,
         as: :select,
         collection: array_to_select_collection(Legislation::FRAMEWORKS)

  config.batch_actions = false

  index do
    column :title, &:title_summary_link
    column :date_passed
    column :framework
    column :location
    column :document_types

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :title
      f.input :description, as: :trix
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
      super.includes(:location, :document_types)
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
