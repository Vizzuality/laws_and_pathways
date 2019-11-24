ActiveAdmin.register Instrument do
  menu parent: 'Laws', priority: 6

  permit_params :name, :instrument_type_id

  config.batch_actions = false
  config.sort_order = 'name_asc'

  decorate_with InstrumentDecorator

  filter :name_contains, label: 'Name'
  filter :instrument_type

  index do
    column :name, :name_link
    column :instrument_type

    actions
  end

  show do
    attributes_table do
      row :name
      row :instrument_type
    end

    active_admin_comments
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
      f.input :instrument_type
    end

    f.actions
  end

  controller do
    include DiscardableController
  end
end
