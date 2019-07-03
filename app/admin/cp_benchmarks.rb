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
      f.input :benchmarks, as: :text, wrapper_html: {data: {controller: 'handsontable'}}

      # f.fields_for :benchmarks do |b|
      #   b.input :name
      #   b.input :emissions, as: :text
      # end
    end

    f.actions
  end
end
