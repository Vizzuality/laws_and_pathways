ActiveAdmin.register PublicActivity::Activity do
  config.per_page = 30
  config.batch_actions = false

  menu parent: 'Administration', priority: 3, label: 'Users Activity'

  decorate_with PublicActivity::ActivityDecorator

  actions :all, except: [:new, :create]

  filter :trackable_type, label: 'Record Type'
  filter :trackable_id_equals, label: 'Record ID'
  filter :owner_id_equals, label: 'User ID'
  filter :key_contains, label: 'Action details contains'
  filter :updated_at

  index title: 'Users Activity' do
    column 'Record Type', :trackable_type
    column 'Record ID', :trackable_id
    column 'User', :owner
    column 'Activity details', &:activity_details
    column 'Record', :trackable, &:trackable_link
    column :updated_at, &:updated_at_display
  end
end
