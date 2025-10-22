ActiveAdmin.register ASCOR::Assessment do
  config.sort_order = 'assessment_date_desc'
  includes :country

  menu label: 'Assessments', parent: 'ASCOR', priority: 5

  permit_params :country_id, :assessment_date, :publication_date, :notes,
                results_attributes: [:id, :assessment_id, :indicator_id, :answer, :source, :year, :_destroy]

  filter :country
  filter :assessment_date, as: :select

  data_export_sidebar 'ASCORAssessments', display_name: 'ASCOR Assessments'

  index do
    selectable_column
    id_column
    column :country, sortable: 'ascor_countries.name'
    column :assessment_date
    column :publication_date

    actions
  end

  show do
    attributes_table do
      row :id
      row :country
      row :assessment_date
      row :publication_date
      row 'Research Notes', &:notes
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
      f.input :notes, label: 'Research Notes'
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
    pillar_order = %w[EP CP CF]
    areas = ASCOR::AssessmentIndicator.where(indicator_type: 'area').order('length(code), code').to_a
    indicators = ASCOR::AssessmentIndicator.where(indicator_type: 'indicator').order(:id).to_a
    metrics = ASCOR::AssessmentIndicator.where(indicator_type: 'metric').order(:id).to_a

    areas_by_pillar = areas.group_by { |a| a.code.to_s.split('.').first }
    indicators_by_area = indicators.group_by { |i| i.code.to_s.split('.')[0..1].join('.') }
    metrics_by_indicator = metrics.group_by { |m| m.code.to_s.split('.')[0..2].join('.') }

    ordered = []
    pillar_order.each do |pillar_key|
      (areas_by_pillar[pillar_key] || []).each do |area|
        ordered << area
        (indicators_by_area[area.code.to_s] || []).each do |ind|
          ordered << ind
          (metrics_by_indicator[ind.code.to_s] || []).each { |m| ordered << m }
        end
      end
    end

    ordered.select { |i| i.indicator_type != 'pillar' && !%w[EP.1.a.i EP.1.a.ii].include?(i.code.to_s) }.each do |indicator|
      column "#{indicator.indicator_type} #{indicator.code}", humanize_name: false do |resource|
        controller.assessment_results[[resource.id, indicator.id]]&.first&.answer
      end
    end
    ordered.select { |i| i.indicator_type.in?(%w[indicator metric]) }.each do |indicator|
      column "source #{indicator.indicator_type} #{indicator.code}", humanize_name: false do |resource|
        controller.assessment_results[[resource.id, indicator.id]]&.first&.source
      end
    end
    ordered.select { |i| i.indicator_type == 'metric' }.each do |indicator|
      column "year #{indicator.indicator_type} #{indicator.code}", humanize_name: false do |resource|
        controller.assessment_results[[resource.id, indicator.id]]&.first&.year
      end
    end
    column 'Research Notes', &:notes
  end

  controller do
    def assessment_results
      @assessment_results ||= ASCOR::AssessmentResult.all.group_by { |r| [r.assessment_id, r.indicator_id] }
    end
  end
end
