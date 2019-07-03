ActiveAdmin.register Location do
  permit_params :name, :iso, :region, :federal, :federal_details, :approach_to_climate_change,
                :legislative_process, :location_type, :political_groups_list

  filter :federal
  filter :iso_equals, label: 'ISO'
  filter :name_contains, label: 'Name'
  filter :region, as: :check_boxes, collection: Location::REGIONS
  filter :political_groups, as: :check_boxes, collection: PoliticalGroup.all

  index do
    selectable_column
    column :name do |location|
      link_to location.name, admin_location_path(location)
    end
    column :location_type do |location|
      location.location_type.humanize
    end
    column 'ISO', :iso
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :location_type, as: :hidden, input_html: {value: 'country'}
      f.input :name
      f.input :iso
      f.input :region, as: :select, collection: Location::REGIONS
      f.input :federal
      f.input :federal_details
      f.input :approach_to_climate_change
      f.input :legislative_process
      f.input :political_groups_list, as: :tags, collection: PoliticalGroup.all.map(&:name)
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
