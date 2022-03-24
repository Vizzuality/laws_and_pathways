ActiveAdmin.register CP::Assessment do
  config.sort_order = 'publication_date_desc'

  menu parent: 'TPI', priority: 2, label: 'Carbon Performance Assessments'

  decorate_with CP::AssessmentDecorator

  permit_params :assessment_date, :publication_date, :company_id, :last_reported_year,
                :assumptions, :cp_alignment, :cp_alignment_2025, :cp_alignment_2035,
                :region, :cp_regional_alignment_2025, :cp_regional_alignment_2035, :cp_regional_alignment_2050,
                :years_with_targets_string, :emissions

  filter :assessment_date
  filter :publication_date, as: :select, collection: proc { CP::Assessment.all_publication_dates }
  filter :company
  filter :company_sector_id, as: :select, collection: proc { TPISector.all }

  data_export_sidebar 'CPAssessments'

  show do
    attributes_table do
      row :id
      row :company
      row :assessment_date
      row :publication_date
      row :last_reported_year
      row :cp_alignment
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

    panel 'Emissions/Targets' do
      render 'admin/cp/emissions_table', emissions: resource.emissions
    end

    active_admin_comments
  end

  form partial: 'form'

  index do
    column :title, &:title_link
    column :company
    column :cp_alignment
    column :cp_alignment_2025
    column :cp_alignment_2035
    column :assessment_date
    column :publication_date
    actions
  end

  csv do
    year_columns = collection.flat_map(&:emissions_all_years).uniq.sort

    column :id
    column('Company Id') { |a| a.company.id }
    column(:company) { |a| a.company.name }
    column :assessment_date
    column :publication_date, &:publication_date_csv
    column :last_reported_year
    year_columns.map do |year|
      column year do |a|
        a.emissions[year]
      end
    end
    column :assumptions
    column :cp_alignment
    column :cp_alignment_2025
    column :cp_alignment_2035
    column :region
    column :cp_regional_alignment_2025
    column :cp_regional_alignment_2035
    column :cp_regional_alignment_2050
    column :years_with_targets, &:years_with_targets_csv
  end

  controller do
    def scoped_collection
      super.includes(:company)
    end
  end
end
