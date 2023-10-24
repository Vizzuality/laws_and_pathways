ActiveAdmin.register ASCOR::Pathway do
  config.sort_order = 'id_asc'
  includes :country

  menu label: 'Pathways', parent: 'ASCOR', priority: 3

  permit_params :country_id, :publication_date, :assessment_date, :emissions_metric, :emissions_boundary, :units,
                :emissions, :last_historical_year, :trend_1_year, :trend_3_year, :trend_5_year, :trend_source, :trend_year,
                :recent_emission_level, :recent_emission_source, :recent_emission_year

  filter :country, as: :select, collection: -> { ASCOR::Country.all.order(:name) }
  filter :assessment_date, as: :select, collection: -> { ASCOR::Pathway.pluck(:assessment_date).uniq }
  filter :emissions_metric, as: :select, collection: -> { ASCOR::EmissionsMetric::VALUES }
  filter :emissions_boundary, as: :select, collection: -> { ASCOR::EmissionsBoundary::VALUES }

  data_export_sidebar 'ASCORPathways', display_name: 'ASCOR Pathways'

  index do
    selectable_column
    id_column
    column :country, sortable: 'ascor_countries.name'
    column :assessment_date
    column :emissions_metric
    column :emissions_boundary
    column :units

    actions
  end

  show do
    attributes_table do
      row :id
      row :country
      row :assessment_date
      row :publication_date
      row :emissions_metric
      row :emissions_boundary
      row :units
      row :last_historical_year
      row 'metric EP1.a.i', &:recent_emission_level
      row 'source EP1.a.i', &:recent_emission_source
      row 'year EP1.a.i', &:recent_emission_year
      row 'metric EP1.a.ii 1-year', &:trend_1_year
      row 'metric EP1.a.ii 3-year', &:trend_3_year
      row 'metric EP1.a.ii 5-year', &:trend_5_year
      row 'source metric EP1.a.ii', &:trend_source
      row 'year metric EP1.a.ii', &:trend_year
      row :created_at
      row :updated_at
    end

    panel 'Pathway emission values' do
      render 'admin/cp/emissions_table', emissions: resource.emissions
    end

    active_admin_comments
  end

  form html: {'data-controller' => 'check-modified with-emission-table-form'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :country, as: :select, collection: ASCOR::Country.all.order(:name)
      f.input :assessment_date, as: :datepicker
      f.input :publication_date, as: :datepicker
      f.input :emissions_metric, as: :select, collection: ASCOR::EmissionsMetric::VALUES
      f.input :emissions_boundary, as: :select, collection: ASCOR::EmissionsBoundary::VALUES
      f.input :units
      f.input :last_historical_year
      f.input :recent_emission_level, label: 'metric EP1.a.i'
      f.input :recent_emission_source, label: 'source EP1.a.i'
      f.input :recent_emission_year, label: 'year EP1.a.i'
      f.input :trend_1_year, label: 'metric EP1.a.ii 1-year'
      f.input :trend_3_year, label: 'metric EP1.a.ii 3-year'
      f.input :trend_5_year, label: 'metric EP1.a.ii 5-year'
      f.input :trend_source, label: 'source metric EP1.a.ii'
      f.input :trend_year, label: 'year metric EP1.a.ii'
      f.input :emissions, as: :hidden, input_html: {value: f.object.emissions.to_json, id: 'input_emissions'}
    end

    div class: 'panel' do
      h3 'Pathway emission values'
      div class: 'panel-contents padding-20' do
        render 'admin/cp/emissions_table_edit', f: f
      end
    end

    f.actions
  end

  csv do
    year_columns = ASCOR::Pathway.select(:emissions).flat_map(&:emissions_all_years).uniq.sort

    column :id
    column(:country) { |b| b.country.name }
    column(:assessment_date)  { |b| b.assessment_date.strftime '%m/%d/%y' }
    column(:publication_date) { |b| b.publication_date.to_s(:year_month) }
    column :emissions_metric
    column :emissions_boundary
    column :units
    column :last_historical_year
    column 'metric EP1.a.i', humanize_name: false, &:recent_emission_level
    column 'source EP1.a.i', humanize_name: false, &:recent_emission_source
    column 'year EP1.a.i', humanize_name: false, &:recent_emission_year
    column 'metric EP1.a.ii 1-year', humanize_name: false, &:trend_1_year
    column 'metric EP1.a.ii 3-year', humanize_name: false, &:trend_3_year
    column 'metric EP1.a.ii 5-year', humanize_name: false, &:trend_5_year
    column 'source metric EP1.a.ii', humanize_name: false, &:trend_source
    column 'year metric EP1.a.ii', humanize_name: false, &:trend_year
    year_columns.map do |year|
      column year do |resource|
        resource.emissions[year]
      end
    end
  end
end
