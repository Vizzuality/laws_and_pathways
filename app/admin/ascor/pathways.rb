ActiveAdmin.register ASCOR::Pathway do
  config.sort_order = 'country_id_asc'
  includes :country

  menu label: 'Pathways', parent: 'ASCOR', priority: 3

  permit_params :country_id, :publication_date, :assessment_date, :emissions_metric, :emissions_boundary, :land_use, :units,
                :emissions, :last_reported_year, :trend_1_year, :trend_3_year, :trend_5_year

  filter :country, as: :select, collection: -> { ASCOR::Country.all.order(:name) }
  filter :assessment_date, as: :select, collection: -> { ASCOR::Pathway.pluck(:assessment_date).uniq }
  filter :emissions_metric, as: :select, collection: -> { ASCOR::EmissionsMetric::VALUES }
  filter :emissions_boundary, as: :select, collection: -> { ASCOR::EmissionsBoundary::VALUES }
  filter :land_use, as: :select, collection: -> { ASCOR::LandUse::VALUES }

  data_export_sidebar 'ASCORPathways', display_name: 'ASCOR Pathways'

  index do
    column :country
    column :assessment_date
    column :emissions_metric
    column :emissions_boundary
    column :land_use
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
      row :land_use
      row :units
      row :last_reported_year
      row :trend_1_year
      row :trend_3_year
      row :trend_5_year
      row :created_at
      row :updated_at
    end

    panel 'Benchmark emission values' do
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
      f.input :land_use, as: :select, collection: ASCOR::LandUse::VALUES
      f.input :units
      f.input :last_reported_year
      f.input :trend_1_year
      f.input :trend_3_year
      f.input :trend_5_year
      f.input :emissions, as: :hidden, input_html: {value: f.object.emissions.to_json, id: 'input_emissions'}
    end

    div class: 'panel' do
      h3 'Benchmark emission values'
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
    column :land_use
    column :units
    column :last_reported_year
    year_columns.map do |year|
      column year do |benchmark|
        benchmark.emissions[year]
      end
    end
    column '1-year trend', &:trend_1_year
    column '3-year trend', &:trend_3_year
    column '5-year trend', &:trend_5_year
  end
end
