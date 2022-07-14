ActiveAdmin.register BankAssessment do
  config.sort_order = 'assessment_date_desc'

  menu parent: 'TPI', priority: 1, label: 'Bank Assessments'

  decorate_with BankAssessmentDecorator

  actions :all, except: [:new, :create, :edit, :update]

  filter :assessment_date
  filter :bank

  data_export_sidebar 'BankAssessments', display_name: 'Assessments'

  show do
    attributes_table do
      row :id
      row :bank
      row :assessment_date
      row :notes
      row :created_at
      row :updated_at
    end

    panel 'Questions' do
      table_for resource.results do
        column(:number) { |r| r.indicator.number }
        column(:display_text) { |r| r.indicator.display_text }
        column(:value) { |r| r.percentage || r.answer }
      end
    end

    active_admin_comments
  end

  index do
    column :title, &:title_link
    column :assessment_date
    actions
  end

  controller do
    def scoped_collection
      super.includes(:bank)
    end
  end
end
