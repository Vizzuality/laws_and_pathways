ActiveAdmin.register CP::Benchmark do
  config.sort_order = 'release_date_desc'

  menu parent: 'TPI', priority: 3, label: 'Carbon Performance Benchmarks'

  permit_params :scenario, :sector_id, :release_date, :emissions

  filter :release_date
  filter :sector

  data_export_sidebar 'CP Benchmarks'

  show do
    attributes_table do
      row :id
      row :release_date
      row :sector
      row :scenario
      row :created_at
      row :updated_at
    end

    panel 'Benchmark emission values' do
      render 'admin/cp/emissions_table', emissions: resource.emissions
    end
  end

  index do
    id_column
    column :scenario
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
