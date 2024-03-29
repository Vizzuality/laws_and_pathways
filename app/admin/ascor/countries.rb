ActiveAdmin.register ASCOR::Country do
  config.batch_actions = false
  config.sort_order = 'name_asc'

  menu label: 'Countries', parent: 'ASCOR', priority: 1

  permit_params :name, :iso, :region, :wb_lending_group, :fiscal_monitor_category, :type_of_party, :visibility_status

  filter :iso_contains, label: 'ISO'
  filter :name_contains, label: 'Name'
  filter :region, as: :check_boxes, collection: proc { Geography::REGIONS }

  data_export_sidebar 'ASCORCountries', display_name: 'ASCOR Countries'

  index do
    selectable_column
    id_column
    column :name
    column 'Country ISO code', :iso
    column :region
    tag_column :visibility_status

    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row 'Country ISO code', &:iso
      row :region
      row 'World Bank lending group', &:wb_lending_group
      row 'International Monetary Fund fiscal monitor category', &:fiscal_monitor_category
      row 'Type of Party to the United Nations Framework Convention on Climate Change', &:type_of_party
      row :visibility_status
    end

    active_admin_comments
  end

  form do |f|
    semantic_errors(*f.object.errors.attribute_names)

    f.inputs do
      f.input :name
      f.input :iso, label: 'Country ISO code'
      f.input :region
      f.input :wb_lending_group, as: :select, collection: ASCOR::Country::LENDING_GROUPS, label: 'World Bank lending group'
      f.input :fiscal_monitor_category, as: :select, collection: ASCOR::Country::MONITOR_CATEGORIES,
                                        label: 'International Monetary Fund fiscal monitor category'
      f.input :type_of_party, as: :select, collection: ASCOR::Country::TYPE_OF_PARTY,
                              label: 'Type of Party to the United Nations Framework Convention on Climate Change'
      f.input :visibility_status, as: :select, collection: ASCOR::Country::VISIBILITY
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
    column 'Type of Party to the United Nations Framework Convention on Climate Change', humanize_name: false, &:type_of_party
    column :visibility_status
  end
end
