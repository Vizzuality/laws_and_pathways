ActiveAdmin.register Sector do
  config.batch_actions = false

  menu priority: 5

  permit_params :name

  filter :name_contains

  sidebar 'Export / Import', if: -> { collection.any? }, only: :index do
    ul do
      li do
        a 'Download All CP Benchmarks CSV', href: cp_benchmarks_admin_sectors_path
      end
    end
    hr
  end

  index do
    column :name do |sector|
      link_to sector.name, admin_sector_path(sector)
    end
    column :slug
    actions
  end

  collection_action :cp_benchmarks, method: :get do
    exporter = CSVExport::CPBenchmarks.new(CP::Benchmark.all)

    send_data exporter.call, filename: 'cp_benchmarks.csv'
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :name
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
            resource.cp_benchmarks.latest_first.map do |benchmark|
              panel "Released in #{benchmark.date.strftime('%B %Y')}", class: 'benchmark' do
                table_for benchmark.benchmarks, class: 'cell-padding-sm cell-centered' do
                  column :name do |b|
                    b['name']
                  end
                  benchmark.benchmarks_all_years.map do |year|
                    column year do |b|
                      b['values'][year]
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
    end

    f.actions
  end
end
