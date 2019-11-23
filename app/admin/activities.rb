ActiveAdmin.register PublicActivity::Activity do
  config.per_page = 30

  menu parent: 'Administration', priority: 3, label: 'Users Activity'

  decorate_with PublicActivity::ActivityDecorator

  index do
    column 'Record Type', :trackable_type
    column 'Record ID', :trackable_id
    column 'User', :owner
    column 'Activity', &:activity_details
    column 'Record', :trackable, &:trackable_link
    column :updated_at, &:updated_at_display
  end
end
