ActiveAdmin.register ASCOR::Assessment do
  config.sort_order = 'assessment_date_desc'
  includes :country

  menu label: 'Assessments', parent: 'ASCOR', priority: 5

  permit_params :country_id, :assessment_date, :publication_date, :notes,
                results_attributes: [:id, :assessment_id, :indicator_id, :answer, :source, :_destroy]

  filter :country
  filter :assessment_date, as: :select

  data_export_sidebar 'ASCORAssessments', display_name: 'ASCOR Assessments'

  index do
    selectable_column
    id_column
    column :country, sortable: 'ascor_countries.name'
    column :assessment_date
    column :publication_date
    column :notes

    actions
  end

  show do
    attributes_table do
      row :id
      row :country
      row :assessment_date
      row :publication_date
      row :notes
      row :created_at
      row :updated_at
    end

    panel 'Assessment Results' do
      table_for resource.results.includes(:indicator).order(:indicator_id) do
        column(:indicator)
        column(:answer)
        column(:source)
        column(:year)
      end
    end

    active_admin_comments
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :country, as: :select, collection: ASCOR::Country.all.order(:name)
      f.input :assessment_date, as: :datepicker
      f.input :publication_date, as: :datepicker
      f.input :notes
    end

    f.has_many :results, allow_destroy: true, heading: false do |ff|
      ff.inputs 'Assessment Results' do
        ff.input :indicator, as: :select, collection: ASCOR::AssessmentIndicator.all.order(:code)
        ff.input :answer
        ff.input :source
        ff.input :year
      end
    end

    f.actions
  end

  csv do
    column :id
    column :country do |resource|
      resource.country.name
    end
    column :assessment_date
    column :publication_date
    ASCOR::AssessmentIndicator.where.not(indicator_type: 'pillar')
      .where.not(code: %w[EP.1.a.i EP.1.a.ii]).order(:id).all.each do |indicator|
      column "#{indicator.indicator_type} #{indicator.code}", humanize_name: false do |resource|
        controller.assessment_results[[resource.id, indicator.id]]&.first&.answer
      end
    end
    ASCOR::AssessmentIndicator.where(indicator_type: %w[indicator metric]).order(:id).all.each do |indicator|
      column "source #{indicator.indicator_type} #{indicator.code}", humanize_name: false do |resource|
        controller.assessment_results[[resource.id, indicator.id]]&.first&.source
      end
    end
    ASCOR::AssessmentIndicator.where(indicator_type: 'metric').order(:id).all.each do |indicator|
      column "year #{indicator.indicator_type} #{indicator.code}", humanize_name: false do |resource|
        controller.assessment_results[[resource.id, indicator.id]]&.first&.year
      end
    end
    column :notes
  end

  controller do
    def assessment_results
      @assessment_results ||= ASCOR::AssessmentResult.all.group_by { |r| [r.assessment_id, r.indicator_id] }
    end
  end
end
