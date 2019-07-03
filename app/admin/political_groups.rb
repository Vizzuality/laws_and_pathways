ActiveAdmin.register PoliticalGroup do
  permit_params :name

  filter :name_contains, label: 'Name'
end
