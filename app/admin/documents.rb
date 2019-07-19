ActiveAdmin.register Document do
  menu priority: 3

  decorate_with DocumentDecorator

  filter :name_contains
  filter :documentable_type, label: 'Attached to'

  config.batch_actions = false

  actions :all, except: [:new, :edit, :create, :update]

  index do
    column :name_link
    column :open_link
    column 'Attached To', :documentable
    column :last_verified_on
    actions
  end
end
