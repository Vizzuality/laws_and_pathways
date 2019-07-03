ActiveAdmin.register CP::Benchmark do
  permit_params :date, :current, :benchmarks, :sector_id

  filter :sector
  filter :current

  config.batch_actions = false

  index do
    column :date
    column :sector
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :sector
      f.input :date
      f.input :benchmarks, as: :text
    end

    f.actions
  end
end
