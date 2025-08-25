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

    panel 'Questions (Active Indicators Only)' do
      # Show only results from active indicators
      active_results = resource.results.joins(:indicator).where(bank_assessment_indicators: {active: true})

      if active_results.any?
        table_for active_results.decorate do
          column(:number) { |r| r.indicator.number }
          column(:display_text) { |r| r.indicator.display_text }
          column(:value)
          column(:version) { |r| r.indicator.version }
        end
      else
        para 'No results found for active indicators.'
      end

      # Add link to manage indicators
      para do
        link_to 'Manage Bank Assessment Indicators', admin_bank_assessment_indicators_path, class: 'button'
      end
    end

    # Optional: Show all results (including inactive indicators)
    panel 'All Questions (Including Inactive Indicators)' do
      all_results = resource.results.includes(:indicator).order('bank_assessment_indicators.number')

      if all_results.any?
        table_for all_results.decorate do
          column(:number) { |r| r.indicator.number }
          column(:display_text) { |r| r.indicator.display_text }
          column(:value)
          column(:version) { |r| r.indicator.version }
          column(:active) { |r| r.indicator.active? ? 'Yes' : 'No' }
        end
      else
        para 'No results found.'
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
    # For CSV export, use only active indicators by default
    active_indicators = BankAssessmentIndicator.active.order(:indicator_type, :number)

    column :id
    column(:bank) { |a| a.bank.name }
    column :assessment_date

    # Export results for active indicators only
    active_indicators.each do |indicator|
      type = indicator.indicator_type
      number = indicator.number
      column "#{type} #{number}", humanize_name: false do |a|
        result = a.results.joins(:indicator).find_by(bank_assessment_indicators: {id: indicator.id})
        result.percentage || result.answer if result
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
