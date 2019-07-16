ActiveAdmin.register Litigation do
  menu priority: 3

  permit_params :title, :location_id, :document_type, :summary, :core_objective

  filter :title_contains
  filter :summary_contains
  filter :location
  filter :document_type, as: :select, collection: proc {
    array_to_select_collection(Litigation::DOCUMENT_TYPES)
  }

  config.batch_actions = false

  index do
    column :title, class: 'max-width-300' do |l|
      link_to l.title, admin_litigation_path(l)
    end
    column :document_type do |l|
      l.document_type.humanize
    end
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
          row :document_type do
            resource.document_type.humanize
          end
          row :citation_reference_number
          row :summary do
            resource.summary.html_safe
          end
          row :core_objective do
            resource.core_objective.html_safe
          end
          row :created_at
          row :updated_at
        end
      end

      tab :sides do
        panel 'Litigation Sides' do
          table_for resource.litigation_sides.order(:side_type) do
            column :side_type do |s|
              s.side_type.humanize
            end
            column :name
            column :party_type do |s|
              s.party_type&.humanize
            end
          end
        end
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :title
      f.input :location
      f.input :document_type, as: :select, collection: array_to_select_collection(Litigation::DOCUMENT_TYPES)
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
