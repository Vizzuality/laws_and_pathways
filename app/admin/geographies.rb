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
                political_group_ids: []

  filter :federal
  filter :iso_equals, label: 'ISO'
  filter :name_contains, label: 'Name'
  filter :region, as: :check_boxes, collection: proc { Geography::REGIONS }
  filter :political_groups,
         as: :check_boxes,
         collection: proc { PoliticalGroup.all }

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

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :geography_type, as: :hidden, input_html: {value: 'country'}
      f.input :name
      f.input :iso
      f.input :region, as: :select, collection: Geography::REGIONS
      f.input :federal, input_html: {id: 'federal'}
      f.input :federal_details,
              wrapper_html: {data: {controller: 'dependent-input', depends_on: 'federal'}}
      f.input :indc_url, as: :string
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
    def apply_filtering(chain)
      super(chain).distinct
    end
  end
end
