ActiveAdmin.register InstrumentType do
  menu parent: 'Laws', priority: 7
  config.batch_actions = false
  config.sort_order = 'name_asc'

  permit_params :name

  decorate_with InstrumentTypeDecorator

  filter :name_contains, label: 'Name'

  index do
    column :name, sortable: :name, &:name_link

    actions
  end

  show do
    attributes_table do
      row :name
      list_row 'Instruments', :instrument_links
    end

    active_admin_comments
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
    end

    f.actions
  end

  controller do
    include DiscardableController
  end
end
