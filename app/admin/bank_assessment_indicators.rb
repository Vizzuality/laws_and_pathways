ActiveAdmin.register BankAssessmentIndicator do
  config.sort_order = 'id_asc'

  menu parent: 'TPI', priority: 1, label: 'Bank Assessment Indicators'

  actions :all, except: [:new, :create]

  filter :number
  filter :text

  data_export_sidebar 'Bank Assessement Indicators'

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

  index do
    id_column
    column :indicator_type
    column :number
    column :text
    actions
  end
end
