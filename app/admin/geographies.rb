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

      tab :events do
        panel 'Geography Events' do
          table_for resource.events.decorate do
            column :date
            column :event_type
            column :title
            column :description
            column 'URL', &:url_link
          end
        end
      end
    end
  end

  index do
    column 'Name', :name_link
    column :geography_type
    column 'ISO', :iso
    column :created_by
    column :updated_by
    tag_column :visibility_status

    actions
  end

  form partial: 'form'

  controller do
    def apply_filtering(chain)
      super(chain).distinct
    end

    def destroy
      destroy_command = ::Command::Destroy::Geography.new(resource.object)

      results = if destroy_command.call
                  {notice: 'Successfully deleted selected Geography'}
                else
                  {alert: 'Could not delete selected Geography'}
                end

      redirect_to admin_geographies_path(scope: current_scope.name), results
    end
  end
end
