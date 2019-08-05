ActiveAdmin.register Location do
  menu parent: 'Locations', priority: 1

  decorate_with LocationDecorator

  scope('All', &:all)
  scope('Draft', &:draft)
  scope('Pending', &:pending)
  scope('Published', &:published)
  scope('Archived', &:archived)

  permit_params :name, :iso, :region, :federal, :federal_details,
                :legislative_process, :location_type,
                :visibility_status, political_group_ids: []

  filter :federal
  filter :iso_equals, label: 'ISO'
  filter :name_contains, label: 'Name'
  filter :region, as: :check_boxes, collection: proc { Location::REGIONS }
  filter :political_groups,
         as: :check_boxes,
         collection: proc { PoliticalGroup.all }

  config.batch_actions = false

  sidebar 'Publishing Status', only: :show do
    attributes_table do
      tag_row :visibility_status, interactive: true
    end
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :name
          row :iso
          row :location_type
          row :region
          row :federal
          row :federal_details if resource.federal?
          row :legislative_process
          row :political_groups
          row :created_at
          row :updated_at
        end
      end
    end
  end

  index do
    column 'Name', :name_link
    column :location_type
    column 'ISO', :iso
    tag_column :visibility_status

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :location_type, as: :hidden, input_html: {value: 'country'}
      f.input :name
      f.input :iso
      f.input :region, as: :select, collection: Location::REGIONS
      f.input :federal, input_html: {id: 'federal'}
      f.input :federal_details,
              wrapper_html: {data: {controller: 'dependent-input', depends_on: 'federal'}}
      f.input :legislative_process, as: :trix
      f.input :political_group_ids,
              label: 'Political Groups',
              as: :tags,
              collection: PoliticalGroup.all
      f.input :visibility_status, as: :select
    end

    f.actions
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end

    def apply_filtering(chain)
      super(chain).distinct
    end
  end
end
