ActiveAdmin.register Governance do
  menu parent: 'Laws', priority: 8

  permit_params :name, :governance_type_id

  config.batch_actions = false

  decorate_with GovernanceDecorator

  filter :name_contains, label: 'Name'
  filter :governance_type

  index do
    column :name, :name_link
    column :governance_type

    actions
  end

  show do
    attributes_table do
      row :name
      row :governance_type
    end

    active_admin_comments
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs do
      f.input :name
      f.input :governance_type
    end

    f.actions
  end

  controller do
    include DiscardableController
  end
end
