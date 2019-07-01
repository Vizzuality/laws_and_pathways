ActiveAdmin.register Company do
  permit_params :name, :isin, :sector_id, :location_id, :headquarter_location_id,
                :size

  filter :isin_contains, label: 'ISIN'
  filter :name_contains, label: 'Name'
  filter :location
  filter :headquarter_location
  filter :size, as: :check_boxes, collection: array_to_select_collection(Company::SIZES)

  index do
    selectable_column
    column :name do |company|
      link_to company.name, admin_company_path(company)
    end
    column 'ISIN', :isin
    column :size do |company|
      company.size.humanize
    end
    column :location
    column :headquarter_location
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
      f.input :isin, label: 'ISIN'
      f.input :sector
      f.input :location
      f.input :headquarter_location
      f.input :ca100
      f.input :size, as: :select, collection: array_to_select_collection(Company::SIZES)
    end

    f.actions
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
