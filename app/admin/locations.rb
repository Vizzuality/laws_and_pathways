ActiveAdmin.register Location do
  permit_params :name, :iso, :region, :federal, :federal_details, :approach_to_climate_change,
                :legislative_process, :location_type

  filter :federal
  filter :id_equals
  filter :iso_equals
  filter :name_contains
  filter :region, as: :check_boxes, collection: Location::REGIONS

  index do
    selectable_column
    column :name do |location|
      link_to location.name, admin_location_path(location)
    end
    column :location_type
    column :iso
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
    end

    f.actions
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
