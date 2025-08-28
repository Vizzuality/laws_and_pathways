ActiveAdmin.register CP::Assessment do
  config.sort_order = 'publication_date_desc'

  menu parent: 'TPI', priority: 4, label: 'Carbon Performance Assessments'

  decorate_with CP::AssessmentDecorator

  permit_params :sector_id, :subsector_id, :assessment_date, :publication_date, :cp_assessmentable_id, :last_reported_year,
                :assumptions, :cp_alignment_2025, :cp_alignment_2027, :cp_alignment_2028, :cp_alignment_2030, :cp_alignment_2035,
                :cp_alignment_2050,
                :region, :cp_regional_alignment_2025, :cp_regional_alignment_2027, :cp_regional_alignment_2028,
                :cp_regional_alignment_2030, :cp_regional_alignment_2035, :cp_regional_alignment_2050, :years_with_targets_string,
                :emissions, :company_subsector_id, :subsector_id,
                :assessment_date_flag,
                cp_matrices_attributes: [:id, :portfolio, :cp_alignment_2025,
                                         :cp_alignment_2030, :cp_alignment_2035, :cp_alignment_2050, :_destroy]

  filter :assessment_date
  filter :publication_date, as: :select, collection: proc { CP::Assessment.all_publication_dates }
  filter :company, as: :select, collection: proc { Company.all }
  filter :company_sector_id, as: :select, collection: proc { TPISector.companies.all }
  filter :bank, as: :select, collection: proc { Bank.all }

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
        link_to '<strong>Upload</strong> Bank CPAssessments 2030'.html_safe,
                new_admin_data_upload_path(data_upload: {uploader: 'BankCPAssessments2030'})
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
      row :subsector
      row :assessment_date
      row :assessment_date_flag
      row :publication_date
      row :last_reported_year
      row :cp_alignment_2050
      row :cp_alignment_2025
      row :cp_alignment_2027
      row :cp_alignment_2028
      row :cp_alignment_2030
      row :cp_alignment_2035
      row :region
      row :cp_regional_alignment_2025
      row :cp_regional_alignment_2027
      row :cp_regional_alignment_2028
      row :cp_regional_alignment_2030
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
        column :cp_alignment_2030
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
    column :subsector do |record|
      if record.subsector_id.present?
        record.subsector&.name
      elsif record.cp_assessmentable_type == 'Company' && record.company_subsector_id.present?
        record.company_subsector&.subsector
      end
    end
    column :cp_alignment_2050
    column :cp_alignment_2025
    column :cp_alignment_2027
    column :cp_alignment_2028
    column :cp_alignment_2030
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
    if params[:cp_assessmentable_type] == 'Company'
      column :subsector do |record|
        record.company_subsector&.subsector
      end
    elsif params[:cp_assessmentable_type] == 'Bank'
      column :subsector do |record|
        record.subsector&.name
      end
    end
    column :assessment_date
    column :assessment_date_flag
    column :publication_date, &:publication_date_csv
    year_columns.map do |year|
      column year do |a|
        a.emissions[year]
      end
    end
    column :assumptions
    column :years_with_targets, &:years_with_targets_csv
    column :last_reported_year

    if params[:cp_assessmentable_type] == 'Company'
      column :cp_alignment_2025
      column :cp_alignment_2027
      column :cp_alignment_2028
      column :cp_alignment_2030
      column :cp_alignment_2035
      column :cp_alignment_2050
      column :cp_regional_alignment_2025
      column :cp_regional_alignment_2027
      column :cp_regional_alignment_2028
      column :cp_regional_alignment_2030
      column :cp_regional_alignment_2035
      column :cp_regional_alignment_2050
    elsif params[:cp_assessmentable_type] == 'Bank'
      %w[2025 2030 2035 2050].each do |year|
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

    def create
      build_resource
      resource.assign_attributes(permitted_params[:cp_assessment])

      if params['cp_assessment']['cp_assessmentable_id'].present?
        resource.cp_assessmentable_type, resource.cp_assessmentable_id =
          params['cp_assessment']['cp_assessmentable_id'].split('::')
      end

      sector_id = params.dig('cp_assessment', 'sector_id')
      subsector_id = params.dig('cp_assessment', 'subsector_id')
      unless subsector_id.blank? || subsector_belongs_to_sector?(sector_id, subsector_id)
        resource.errors.add(:subsector, "doesn't belong to the selected sector")
        render :new and return
      end

      super
    end

    def update
      resource.assign_attributes(permitted_params[:cp_assessment])

      if params['cp_assessment']['cp_assessmentable_id'].present?
        resource.cp_assessmentable_type, resource.cp_assessmentable_id =
          params['cp_assessment']['cp_assessmentable_id'].split('::')
      end

      sector_id = params.dig('cp_assessment', 'sector_id')
      subsector_id = params.dig('cp_assessment', 'subsector_id')
      unless subsector_id.blank? || subsector_belongs_to_sector?(sector_id, subsector_id)
        resource.errors.add(:subsector, "doesn't belong to the selected sector")
        render :edit and return
      end

      super
    end

    def fix_region
      params['cp_assessment']['region'] = nil if params['cp_assessment'] && params['cp_assessment']['region'].blank?
    end

    def scoped_collection
      query = super.includes(:company, :bank, :cp_matrices, :sector, :subsector)
      query = query.where(cp_assessmentable_type: params[:cp_assessmentable_type]) if params[:cp_assessmentable_type].present?
      query
    end

    private

    def subsector_belongs_to_sector?(sector_id, subsector_id)
      return false if sector_id.blank? || subsector_id.blank?

      sector = TPISector.find_by(id: sector_id)
      subsector = Subsector.find_by(id: subsector_id)

      return false unless sector && subsector

      sector.subsectors.include?(subsector)
    end

    def validate_subsector_belongs_to_sector
      sector_id = params.dig('cp_assessment', 'sector_id')
      subsector_id = params.dig('cp_assessment', 'subsector_id')

      return unless subsector_id.present? && !subsector_belongs_to_sector?(sector_id, subsector_id)

      resource.errors.add(:subsector, "doesn't belong to the selected sector")
    end
  end
end
