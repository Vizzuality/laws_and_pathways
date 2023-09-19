ActiveAdmin.register ASCOR::Country do
  config.batch_actions = false
  config.sort_order = 'name_asc'

  menu label: 'Countries', parent: 'ASCOR', priority: 1

  permit_params :name, :iso, :region, :wb_lending_group, :fiscal_monitor_category

  filter :iso_contains, label: 'ISO'
  filter :name_contains, label: 'Name'
  filter :region, as: :check_boxes, collection: proc { Geography::REGIONS }

  data_export_sidebar 'ASCORCountries', display_name: 'ASCOR Countries'

  index do
    column :name
    column 'Country ISO code', :iso
    column :region

    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :iso, label: 'Country ISO code'
      row :region
      row :wb_lending_group, label: 'World Bank lending group'
      row :fiscal_monitor_category, label: 'International Monetary Fund fiscal monitor category'
    end

    active_admin_comments
  end

  form do |f|
    semantic_errors(*f.object.errors.attribute_names)

    f.inputs do
      f.input :name
      f.input :iso, label: 'Country ISO code'
      f.input :region, as: :select, collection: ASCOR::Country::REGIONS
      f.input :wb_lending_group, as: :select, collection: ASCOR::Country::LENDING_GROUPS, label: 'World Bank lending group'
      f.input :fiscal_monitor_category, as: :select, collection: ASCOR::Country::MONITOR_CATEGORIES,
                                        label: 'International Monetary Fund fiscal monitor category'
    end

    f.actions
  end

  csv do
    column :id
    column :name
    column 'Country ISO code', humanize_name: false, &:iso
    column :region
    column 'World Bank lending group', humanize_name: false, &:wb_lending_group
    column 'International Monetary Fund fiscal monitor category', humanize_name: false, &:fiscal_monitor_category
  end
end
