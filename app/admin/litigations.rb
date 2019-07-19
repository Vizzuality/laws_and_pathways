ActiveAdmin.register Litigation do
  menu priority: 3

  decorate_with LitigationDecorator

  permit_params :title, :location_id, :document_type, :summary, :core_objective,
                documents_attributes: [
                  :id, :_destroy, :name, :external_url, :file
                ]

  filter :title_contains
  filter :summary_contains
  filter :location
  filter :document_type, as: :select, collection: proc {
    array_to_select_collection(Litigation::DOCUMENT_TYPES)
  }

  config.batch_actions = false

  index do
    column :title, class: 'max-width-300', &:title_link
    column :document_type
    column :location
    column :citation_reference_number
    actions
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :title
          row :slug
          row :location
          row :document_type
          row :citation_reference_number
          row :summary
          row :core_objective
          row :created_at
          row :updated_at
          list_row 'Documents', :document_list
        end
      end

      tab :sides do
        panel 'Litigation Sides' do
          table_for resource.litigation_sides.order(:side_type).decorate do
            column :side_type
            column :name
            column :party_type
          end
        end
      end
    end
  end

  form partial: 'form'

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
