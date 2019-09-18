ActiveAdmin.register Sector do
  config.batch_actions = false

  menu priority: 5

  permit_params :name, :cp_unit

  filter :name_contains

  index do
    column :name do |sector|
      link_to sector.name, admin_sector_path(sector)
    end
    column 'Carbon Performance Unit', &:cp_unit
    column :slug
    actions
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :name
          row 'Carbon Performance Unit', &:cp_unit
          row :slug
          row :created_at
          row :updated_at
        end
      end
      tab :cp_benchmarks do
        panel 'Carbon Performance Benchmarks' do
          if resource.cp_benchmarks.empty?
            div class: 'padding-20' do
              'No Carbon Performance Benchmarks for this sector yet'
            end
          else
            resource.cp_benchmarks.latest_first.group_by(&:release_date).map do |release_date, benchmarks|
              panel "Released in #{release_date.to_s(:month_and_year)}", class: 'benchmark' do
                all_years = benchmarks.map(&:emissions_all_years).flatten.uniq

                table_for benchmarks.sort_by(&:average_emission).reverse, class: 'cell-padding-sm cell-centered' do
                  column :scenario do |benchmark|
                    link_to benchmark.scenario, edit_admin_cp_benchmark_path(benchmark)
                  end
                  all_years.map do |year|
                    column year do |b|
                      b.emissions[year]
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
      f.input :cp_unit, label: 'Carbon Performance Unit'
    end

    f.actions
  end
end
