ActiveAdmin.register PoliticalGroup do
  menu parent: 'Tags'

  permit_params :name

  filter :name_contains, label: 'Name'
end
