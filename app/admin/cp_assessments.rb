ActiveAdmin.register CP::Assessment do
  config.sort_order = 'publication_date_desc'

  menu parent: 'TPI', priority: 4, label: 'Carbon Performance Assessments'

  decorate_with CP::AssessmentDecorator

  permit_params :sector_id, :assessment_date, :publication_date, :cp_assessmentable_id, :last_reported_year,
                :assumptions, :cp_alignment_2025, :cp_alignment_2035, :cp_alignment_2050,
                :region, :cp_regional_alignment_2025, :cp_regional_alignment_2035,
                :cp_regional_alignment_2050, :years_with_targets_string, :emissions,
                cp_matrices_attributes: [:id, :portfolio, :cp_alignment_2025, :cp_alignment_2035, :cp_alignment_2050, :_destroy]

  filter :assessment_date
  filter :publication_date, as: :select, collection: proc { CP::Assessment.all_publication_dates }
  filter :company
  filter :company_sector_id, as: :select, collection: proc { TPISector.companies.all }
  filter :bank

  scope('Banks') { |scope| scope.where(cp_assessmentable_type: 'Bank') }
  scope('Companies') { |scope| scope.where(cp_assessmentable_type: 'Company') }

  sidebar 'Export / Import', only: :index do
    ul do
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
      li do
        link_to '<strong>Upload</strong> Company CPAssessments'.html_safe,
                new_admin_data_upload_path(data_upload: {uploader: 'CompanyCPAssessments'})
      end
      li do
        link_to '<strong>Upload</strong> Bank CPAssessments 2025'.html_safe,
                new_admin_data_upload_path(data_upload: {uploader: 'BankCPAssessments2025'})
      end
      li do
        link_to '<strong>Upload</strong> Bank CPAssessments 2035'.html_safe,
                new_admin_data_upload_path(data_upload: {uploader: 'BankCPAssessments2035'})
      end
      li do
        link_to '<strong>Upload</strong> Bank CPAssessments 2050'.html_safe,
                new_admin_data_upload_path(data_upload: {uploader: 'BankCPAssessments2050'})
      end
    end
    hr
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
      row :cp_alignment_2035
      row :region
      row :cp_regional_alignment_2025
      row :cp_regional_alignment_2035
      row :cp_regional_alignment_2050
      row :years_with_targets
      row :assumptions
      row :created_at
      row :updated_at
    end

    panel 'CP Matrix values' do
      table_for resource.cp_matrices do
        column :portfolio
        column :cp_alignment_2025
        column :cp_alignment_2035
        column :cp_alignment_2050
      end
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
    column :sector
    column :cp_alignment_2050
    column :cp_alignment_2025
    column :cp_alignment_2035
    column :assessment_date
    column :publication_date
    actions
  end

  csv do
    year_columns = collection.flat_map(&:emissions_all_years).uniq.sort

    column :id
    column "#{params[:cp_assessmentable_type]} Id", &:cp_assessmentable_id
    column :name do |record|
      record.cp_assessmentable.name
    end
    column :region
    column :sector do |record|
      record.sector.name
    end
    column :assessment_date
    column :publication_date, &:publication_date_csv
    year_columns.map do |year|
      column year do |a|
        a.emissions[year]
      end
    end
    column :assumptions
    column :years_with_targets, &:years_with_targets_csv

    if params[:cp_assessmentable_type] == 'Company'
      column :last_reported_year
      column :cp_alignment_2025
      column :cp_alignment_2035
      column :cp_alignment_2050
      column :cp_regional_alignment_2025
      column :cp_regional_alignment_2035
      column :cp_regional_alignment_2050
    elsif params[:cp_assessmentable_type] == 'Bank'
      column :final_disclosure_year
      %w[2025 2035 2050].each do |year|
        CP::Portfolio::NAMES.each do |portfolio|
          column "#{portfolio} #{year}", humanize_name: false do |record|
            record.cp_matrices.detect { |r| r.portfolio == portfolio }.try(:"cp_alignment_#{year}")
          end
        end
      end
    end
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
      query = super.includes(:company, :bank, :cp_matrices, :sector)
      query = query.where(cp_assessmentable_type: params[:cp_assessmentable_type]) if params[:cp_assessmentable_type].present?
      query
    end
  end
end
