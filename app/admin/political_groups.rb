ActiveAdmin.register PoliticalGroup do
  menu parent: 'Locations', priority: 2

  permit_params :name

  filter :name_contains, label: 'Name'
end
