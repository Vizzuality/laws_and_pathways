ActiveAdmin.register TargetScope do
  menu parent: 'Laws', priority: 4

  permit_params :name

  filter :name_contains, label: 'Name'
end
