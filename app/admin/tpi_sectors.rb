ActiveAdmin.register TPISector do
  config.batch_actions = false

  decorate_with TPISectorDecorator

  menu priority: 5, parent: 'TPI'

  permit_params :name, cp_units_attributes: [:id, :unit, :valid_since, :_destroy]

  filter :name_contains

  index do
    column :name, &:name_link
    column 'Carbon Performance Unit', &:latest_cp_unit
    column :slug
    actions
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :name
          list_row 'Carbon Performance Unit', &:cp_units_list
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

    active_admin_comments
  end

  form partial: 'form'
end
