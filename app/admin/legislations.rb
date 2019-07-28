ActiveAdmin.register Legislation do
  config.sort_order = 'date_passed_desc'

  menu parent: 'Laws', priority: 1

  decorate_with LegislationDecorator

  permit_params :title, :date_passed, :description, :framework, :location_id, :law_id

  filter :title_contains, label: 'Title'
  filter :date_passed
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
        column { f.input :date_passed }
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
