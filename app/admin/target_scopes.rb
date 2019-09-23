ActiveAdmin.register TargetScope do
  menu parent: 'Laws', priority: 4
  config.batch_actions = false

  decorate_with TargetScopeDecorator

  permit_params :name

  filter :name_contains, label: 'Name'

  index do
    column :name, :name_link

    actions
  end

  show do
    attributes_table do
      row :name
    end
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
