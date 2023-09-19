ActiveAdmin.register ASCOR::Assessment do
  config.sort_order = 'assessment_date_desc'
  includes :country

  menu label: 'Assessments', parent: 'ASCOR', priority: 5

  permit_params :country_id, :assessment_date, :publication_date, :research_notes, :further_information,
                results_attributes: [:id, :assessment_id, :indicator_id, :answer, :source_name, :source_date,
                                     :source_link, :_destroy]

  filter :country
  filter :assessment_date, as: :select

  data_export_sidebar 'ASCORAssessments', display_name: 'ASCOR Assessments'

  index do
    column :country
    column :assessment_date
    column :publication_date
    column :research_notes

    actions
  end

  show do
    attributes_table do
      row :id
      row :country
      row :assessment_date
      row :publication_date
      row :research_notes
      row :further_information
      row :created_at
      row :updated_at
    end

    panel 'Assessment Results' do
      table_for resource.results.includes(:indicator).order(:id) do
        column(:indicator)
        column(:answer)
        column(:source_name)
        column(:source_date)
        column(:source_link)
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
      f.input :research_notes
      f.input :further_information
    end

    f.has_many :results, allow_destroy: true, heading: false do |ff|
      ff.inputs 'Assessment Results' do
        ff.input :indicator, as: :select, collection: ASCOR::AssessmentIndicator.all.order(:code)
        ff.input :answer
        ff.input :source_name
        ff.input :source_date
        ff.input :source_link
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
    ASCOR::AssessmentIndicator.order(:id).all.each do |indicator|
      if indicator.indicator_type.in? %w[area indicator]
        column "#{indicator.indicator_type.capitalize} #{indicator.code}", humanize_name: false do |resource|
          controller.assessment_results[[resource.id, indicator.id]]&.first&.answer
        end
      end
      next unless indicator.indicator_type.in? %w[indicator custom_indicator]

      column "Source name #{indicator.code}", humanize_name: false do |resource|
        controller.assessment_results[[resource.id, indicator.indicator_type, indicator.code]]&.first&.source_name
      end
      column "Source date #{indicator.code}", humanize_name: false do |resource|
        controller.assessment_results[[resource.id, indicator.indicator_type, indicator.code]]&.first&.source_date
      end
      column "Source link #{indicator.code}", humanize_name: false do |resource|
        controller.assessment_results[[resource.id, indicator.indicator_type, indicator.code]]&.first&.source_link
      end
    end
    column :research_notes
    column :further_information
  end

  controller do
    def assessment_results
      @assessment_results ||= ASCOR::AssessmentResult.group_by { |r| [r.assessment_id, r.indicator_id] }
    end
  end
end
