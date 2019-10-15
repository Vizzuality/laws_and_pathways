ActiveAdmin.register Geography do
  config.batch_actions = false
  config.sort_order = 'name_asc'

  menu parent: 'Geographies', priority: 1

  decorate_with GeographyDecorator

  publishable_scopes
  publishable_sidebar only: :show

  permit_params :name, :iso, :region, :federal, :federal_details,
                :legislative_process, :geography_type, :indc_url,
                :visibility_status,
                :created_by_id, :updated_by_id,
                political_group_ids: [],
                events_attributes: permit_params_for(:events)

  filter :federal
  filter :iso_equals, label: 'ISO'
  filter :name_contains, label: 'Name'
  filter :region, as: :check_boxes, collection: proc { Geography::REGIONS }
  filter :political_groups,
         as: :check_boxes,
         collection: proc { PoliticalGroup.all }

  data_export_sidebar 'Geographies'

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :name
          row :iso
          row(:flag) { |g| g.flag_image(:medium) }
          row :geography_type
          row :region
          row :federal
          row :federal_details if resource.federal?
          row :indc_link
          row :legislative_process
          row :political_groups
          row :updated_at
          row :updated_by
          row :created_at
          row :created_by
        end
      end

      eventable_tab 'Geography Events'
    end

    active_admin_comments
  end

  index do
    column 'Name', :name_link
    column :geography_type
    column 'ISO', :iso
    column 'Flag', :flag_image
    column :created_by
    column :updated_by
    tag_column :visibility_status

    actions
  end

  csv do
    column :id
    column :name
    column :iso
    column :geography_type
    column :region
    column :legislative_process
    column :federal
    column :federal_details
    column :political_groups, &:political_groups_string
    column :visibility_status
  end

  form partial: 'form'

  controller do
    include DiscardableController

    def apply_filtering(chain)
      super(chain).distinct
    end
  end
end
