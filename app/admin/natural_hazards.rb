ActiveAdmin.register NaturalHazard do
  config.sort_order = 'name_asc'

  menu parent: 'Tags'

  permit_params :name

  filter :name_contains, label: 'Name'
end
