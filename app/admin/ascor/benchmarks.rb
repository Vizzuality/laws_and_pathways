ActiveAdmin.register ASCOR::Benchmark do
  config.sort_order = 'country_id_asc'
  includes :country

  menu label: 'Benchmarks', parent: 'ASCOR', priority: 2

  permit_params :country_id, :publication_date, :emissions_metric, :emissions_boundary, :units, :benchmark_type, :emissions

  filter :country, as: :select, collection: -> { ASCOR::Country.all.order(:name) }
  filter :emissions_metric, as: :select, collection: -> { ASCOR::EmissionsMetric::VALUES }
  filter :emissions_boundary, as: :select, collection: -> { ASCOR::EmissionsBoundary::VALUES }
  filter :benchmark_type, as: :select, collection: -> { ASCOR::BenchmarkType::VALUES }

  data_export_sidebar 'ASCORBenchmarks', display_name: 'ASCOR Benchmarks'

  index do
    selectable_column
    id_column
    column :country, sortable: 'ascor_countries.name'
    column :emissions_metric
    column :emissions_boundary
    column :units
    column :benchmark_type

    actions
  end

  show do
    attributes_table do
      row :id
      row :country
      row :publication_date
      row :emissions_metric
      row :emissions_boundary
      row :units
      row :benchmark_type
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
      f.input :publication_date, as: :datepicker
      f.input :emissions_metric, as: :select, collection: ASCOR::EmissionsMetric::VALUES
      f.input :emissions_boundary, as: :select, collection: ASCOR::EmissionsBoundary::VALUES
      f.input :units
      f.input :benchmark_type, as: :select, collection: ASCOR::BenchmarkType::VALUES
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
    year_columns = ASCOR::Benchmark.select(:emissions).flat_map(&:emissions_all_years).uniq.sort

    column :id
    column(:country) { |b| b.country.name }
    column(:publication_date) { |b| b.publication_date.to_s(:year_month) }
    column :emissions_metric
    column :emissions_boundary
    column :units
    column :benchmark_type

    year_columns.map do |year|
      column year do |benchmark|
        benchmark.emissions[year]
      end
    end
  end
end
