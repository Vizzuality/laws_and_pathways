ActiveAdmin.register TargetType do
  menu parent: 'Laws', priority: 5

  permit_params :name

  filter :name_contains, label: 'Name'
end
