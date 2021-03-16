ActiveAdmin.register Geography do
  config.batch_actions = false
  config.sort_order = 'name_asc'

  menu parent: 'Geographies', priority: 1

  decorate_with GeographyDecorator

  publishable_scopes
  publishable_resource_sidebar

  permit_params :name, :iso, :region, :federal, :federal_details,
                :legislative_process, :geography_type,
                :visibility_status, :percent_global_emissions,
                :climate_risk_index, :wb_income_group, :external_litigations_count,
                :created_by_id, :updated_by_id,
                political_group_ids: [],
                events_attributes: permit_params_for(:events)

  filter :federal
  filter :iso_contains, label: 'ISO'
  filter :name_contains, label: 'Name'
  filter :region, as: :check_boxes, collection: proc { Geography::REGIONS }
  filter :political_groups,
         as: :check_boxes,
         collection: proc { PoliticalGroup.all }

  data_export_sidebar 'Geographies', events: true

  action_item :preview, priority: 0, only: :show do
    link_to 'Preview', resource.preview_url
  end

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
          row 'Percentage of Global Emissions', &:percent_global_emissions
          row 'Climate Risk Index', &:climate_risk_index
          row 'World Bank Income Group', &:wb_income_group
          row 'External Litigation Cases Count', &:exteral_litigations_count
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
    column :percent_global_emissions
    column :climate_risk_index
    column :wb_income_group
    column :visibility_status
  end

  form partial: 'form'

  controller do
    include DiscardableController

    def scoped_collection
      return super.includes(:political_groups) if csv_format?

      super
    end

    def apply_filtering(chain)
      super(chain).distinct
    end

    def csv_format?
      request[:format] == 'csv'
    end
  end
end
