ActiveAdmin.register PublicActivity::Activity do
  config.per_page = 30
  config.batch_actions = false

  menu parent: 'Administration', priority: 3, label: 'Users Activity'

  decorate_with PublicActivity::ActivityDecorator

  actions :all, except: [:new, :create]

  filter :trackable_type, label: 'Record Type'
  filter :owner_of_AdminUser_type_email_contains, label: 'User email contains'
  filter :key_contains, label: 'Action details contains'
  filter :updated_at

  index title: 'Users Activity' do
    column 'Record Type', :trackable_type
    column 'Record', :trackable, &:trackable_link
    column 'Activity details', &:activity_details
    column 'User', :owner
    column :updated_at, &:updated_at_display
  end
end
