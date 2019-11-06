ActiveAdmin.register ExternalLegislation do
  config.batch_actions = false

  menu parent: 'Laws', priority: 5, label: 'External Laws'

  decorate_with ExternalLegislationDecorator

  permit_params :name, :url, :geography_id

  filter :name_contains, label: 'Name'
  filter :url_contains, label: 'URL'
  filter :geography

  data_export_sidebar 'External Laws'

  show do
    attributes_table do
      row :name
      row :url
      row :geography
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  index title: 'External Laws' do
    column :name, &:name_summary_link
    column 'URL', :url
    column :geography
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
      f.input :url
      f.input :geography
    end

    f.actions
  end
end
