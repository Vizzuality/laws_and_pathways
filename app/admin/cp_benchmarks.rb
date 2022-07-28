ActiveAdmin.register CP::Benchmark do
  config.sort_order = 'release_date_desc'

  menu parent: 'TPI', priority: 5, label: 'Carbon Performance Benchmarks'

  permit_params :scenario, :sector_id, :release_date, :region, :emissions

  filter :release_date
  filter :sector
  filter :region, as: :select, collection: proc { CP::Benchmark::REGIONS }

  data_export_sidebar 'CPBenchmarks'

  show do
    attributes_table do
      row :id
      row :release_date
      row :sector
      row :scenario
      row :region
      row :created_at
      row :updated_at
    end

    panel 'Benchmark emission values' do
      render 'admin/cp/emissions_table', emissions: resource.emissions
    end

    active_admin_comments
  end

  csv do
    year_columns = collection.flat_map(&:emissions_all_years).uniq.sort

    column :id
    column(:sector) { |b| b.sector.name }
    column(:release_date) { |b| b.release_date.to_s(:year_month) }
    column :scenario
    column :region

    year_columns.map do |year|
      column year do |benchmark|
        benchmark.emissions[year]
      end
    end
  end

  index do
    id_column
    column :scenario
    column :region
    column :sector
    column :release_date
    actions
  end

  form partial: 'form'

  controller do
    def scoped_collection
      super.includes(:sector)
    end
  end
end
