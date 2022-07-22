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
      table_for resource.results.decorate do
        column(:number) { |r| r.indicator.number }
        column(:display_text) { |r| r.indicator.display_text }
        column(:value)
      end
    end

    active_admin_comments
  end

  index do
    column :title, &:title_link
    column :assessment_date
    actions
  end

  csv do
    all_results = BankAssessmentResult
      .includes(:indicator)
      .group_by { |r| [r.bank_assessment_id, r.indicator.indicator_type, r.indicator.number] }

    column :id
    column(:bank) { |a| a.bank.name }
    column :assessment_date
    collection.first.results.map do |result|
      type = result.indicator.indicator_type
      number = result.indicator.number
      column "#{type} #{number}", humanize_name: false do |a|
        res = all_results[[a.id, result.indicator.indicator_type, result.indicator.number]]&.first&.decorate
        res&.value
      end
    end
    column :tpi_notes, &:notes
  end

  controller do
    def scoped_collection
      super.includes(:bank)
    end
  end
end
