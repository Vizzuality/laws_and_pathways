ActiveAdmin.register CP::Assessment do
  config.sort_order = 'publication_date_desc'

  menu parent: 'TPI', priority: 4, label: 'Carbon Performance Assessments'

  decorate_with CP::AssessmentDecorator

  permit_params :sector_id, :assessment_date, :publication_date, :cp_assessmentable_id, :last_reported_year,
                :assumptions, :cp_alignment_2025, :cp_alignment_2027, :cp_alignment_2035, :cp_alignment_2050,
                :region, :cp_regional_alignment_2025, :cp_regional_alignment_2027, :cp_regional_alignment_2035,
                :cp_regional_alignment_2050, :years_with_targets_string, :emissions

  filter :assessment_date
  filter :publication_date, as: :select, collection: proc { CP::Assessment.all_publication_dates }
  filter :company
  filter :company_sector_id, as: :select, collection: proc { TPISector.all }
  filter :bank

  scope('Banks') { |scope| scope.where(cp_assessmentable_type: 'Bank') }
  scope('Companies') { |scope| scope.where(cp_assessmentable_type: 'Company') }

  data_export_sidebar 'CPAssessments', show_display_name: false do
    li do
      link_to 'Download Company CPAssessments CSV',
              params: request.query_parameters.merge(cp_assessmentable_type: 'Company').except(:commit, :format),
              format: 'csv'
    end
    li do
      link_to 'Download Bank CPAssessments CSV',
              params: request.query_parameters.merge(cp_assessmentable_type: 'Bank').except(:commit, :format),
              format: 'csv'
    end
  end

  show do
    attributes_table do
      row :id
      row 'Company/Bank' do |assessment|
        assessment.company.presence || assessment.bank
      end
      row :sector
      row :assessment_date
      row :publication_date
      row :last_reported_year
      row :cp_alignment_2050
      row :cp_alignment_2025
      row :cp_alignment_2027
      row :cp_alignment_2035
      row :region
      row :cp_regional_alignment_2025
      row :cp_regional_alignment_2027
      row :cp_regional_alignment_2035
      row :cp_regional_alignment_2050
      row :years_with_targets
      row :assumptions
      row :created_at
      row :updated_at
    end

    panel 'Emissions/Targets' do
      render 'admin/cp/emissions_table', emissions: resource.emissions
    end

    active_admin_comments
  end

  form partial: 'form'

  index do
    column :title, &:title_link
    column 'Company/Bank' do |assessment|
      assessment.company.presence || assessment.bank
    end
    column :cp_alignment_2050
    column :cp_alignment_2025
    column :cp_alignment_2027
    column :cp_alignment_2035
    column :assessment_date
    column :publication_date
    actions
  end

  csv do
    year_columns = collection.flat_map(&:emissions_all_years).uniq.sort

    column :id
    if params[:cp_assessmentable_type] == 'Company'
      column('Company') { |a| a.company.id }
      column(:name) { |a| a.company.name }
    elsif params[:cp_assessmentable_type] == 'Bank'
      column('Bank') { |a| a.bank.id }
      column(:name) { |a| a.bank.name }
      column(:sector) { |c| c.sector&.name }
    end
    column :assessment_date
    column :publication_date, &:publication_date_csv
    column :last_reported_year
    year_columns.map do |year|
      column year do |a|
        a.emissions[year]
      end
    end
    column :assumptions
    column :cp_alignment_2025
    column :cp_alignment_2027
    column :cp_alignment_2035
    column :cp_alignment_2050
    column :region
    column :cp_regional_alignment_2025
    column :cp_regional_alignment_2027
    column :cp_regional_alignment_2035
    column :cp_regional_alignment_2050
    column :years_with_targets, &:years_with_targets_csv
  end

  controller do
    before_action :fix_region

    before_save do |record|
      if params['cp_assessment']['cp_assessmentable_id'].present?
        record.cp_assessmentable_type, record.cp_assessmentable_id = params['cp_assessment']['cp_assessmentable_id'].split('::')
      end
    end

    def fix_region
      params['cp_assessment']['region'] = nil if params['cp_assessment'] && params['cp_assessment']['region'].blank?
    end

    def scoped_collection
      query = super.includes(:company, :bank)
      query = query.where(cp_assessmentable_type: params[:cp_assessmentable_type]) if params[:cp_assessmentable_type].present?
      query
    end
  end
end
