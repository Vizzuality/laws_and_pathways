ActiveAdmin.register ThemeType do
  menu parent: 'Laws', priority: 9
  config.batch_actions = false

  permit_params :name

  decorate_with ThemeTypeDecorator

  filter :name_contains, label: 'Name'

  index do
    column :name, :name_link

    actions
  end

  show do
    attributes_table do
      row :name
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
