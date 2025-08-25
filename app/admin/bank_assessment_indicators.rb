ActiveAdmin.register BankAssessmentIndicator do
  config.sort_order = 'id_asc'

  menu parent: 'TPI', priority: 1, label: 'Bank Assessment Indicators'

  actions :all, except: [:new, :create]

  filter :number
  filter :text
  filter :indicator_type
  filter :indicator_type, as: :check_boxes, collection: BankAssessmentIndicator::INDICATOR_TYPES
  filter :version
  filter :active

  data_export_sidebar 'BankAssessmentIndicators', display_name: 'Indicators'

  permit_params :number, :indicator_type, :text, :comment, :is_placeholder, :version, :active

  controller do
    def scoped_collection
      # Show only active indicators by default
      super.active
    end
  end

  show do
    attributes_table do
      row :id
      row :number
      row :indicator_type
      row :text
      row :comment
      row :is_placeholder
      row :version
      row :active
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
      f.input :comment
      f.input :is_placeholder
      f.input :version, as: :select, collection: %w[2024 2025], default: '2025'
      f.input :active
    end

    f.actions
  end

  index do
    id_column
    column :indicator_type
    column :number
    column :text
    column :version
    column :active
    actions
  end

  csv do
    column :id
    column :type, &:indicator_type
    column :number
    column :text
    column :version
    column :active
  end

  # Add a sidebar to show version information
  sidebar 'Version Information', only: :index do
    div class: 'panel' do
      h3 'Current Status'
      div do
        strong 'Active Indicators (v2025): '
        span BankAssessmentIndicator.current.count
      end
      div do
        strong 'Legacy Indicators (v2024): '
        span BankAssessmentIndicator.legacy.count
      end
      div do
        strong 'Total Indicators: '
        span BankAssessmentIndicator.count
      end
    end
  end

  # Add actions for version management
  action_item :show_all, only: :index do
    if params[:scope] == 'all'
      link_to 'Show Active Only', admin_bank_assessment_indicators_path
    else
      link_to 'Show All Indicators', admin_bank_assessment_indicators_path(scope: 'all')
    end
  end

  action_item :show_legacy, only: :index do
    link_to 'Show Legacy (v2024)', admin_bank_assessment_indicators_path(scope: 'legacy')
  end

  # Add scopes for different views
  scope :active, default: true
  scope :all
  scope :legacy
end
