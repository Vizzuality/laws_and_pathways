ActiveAdmin.register ASCOR::AssessmentIndicator do
  config.sort_order = 'id_asc'

  menu label: 'Assessment Indicators', parent: 'ASCOR', priority: 4

  actions :all, except: [:new, :create]

  filter :code
  filter :text
  filter :indicator_type, as: :check_boxes, collection: ASCOR::AssessmentIndicator::INDICATOR_TYPES

  data_export_sidebar 'ASCORAssessmentIndicators', display_name: 'ASCOR AssessmentIndicators'

  permit_params :code, :indicator_type, :text

  show do
    attributes_table do
      row :id
      row :code
      row :indicator_type
      row :text
      row :units_or_response_type
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :indicator_type, as: :select, collection: ASCOR::AssessmentIndicator::INDICATOR_TYPES
      f.input :code
      f.input :text
      f.input :units_or_response_type
    end

    f.actions
  end

  index do
    id_column
    column :indicator_type
    column :code
    column :text
    actions
  end

  csv do
    column :id
    column :type, &:indicator_type
    column :code
    column :text
    column :units_or_response_type
  end
end
