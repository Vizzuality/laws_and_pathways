ActiveAdmin.register BankAssessmentIndicator do
  config.sort_order = 'id_asc'

  menu parent: 'TPI', priority: 1, label: 'Bank Assessment Indicators'

  actions :all, except: [:new, :create]

  filter :number
  filter :text
  filter :indicator_type
  filter :indicator_type, as: :check_boxes, collection: BankAssessmentIndicator::INDICATOR_TYPES

  data_export_sidebar 'BankAssessmentIndicators', display_name: 'Indicators'

  permit_params :number, :indicator_type, :text

  show do
    attributes_table do
      row :id
      row :number
      row :indicator_type
      row :text
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :indicator_type, as: :select, collection: BankAssessmentIndicator::INDICATOR_TYPES
      f.input :number
      f.input :text
    end

    f.actions
  end

  index do
    id_column
    column :indicator_type
    column :number
    column :text
    actions
  end

  csv do
    column :id
    column :type, &:indicator_type
    column :number
    column :text
  end
end
