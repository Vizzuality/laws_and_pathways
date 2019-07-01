ActiveAdmin.register Company do
  permit_params :name, :isin, :sector_id, :location_id, :headquarter_location_id,
                :size

  filter :id_equals
  filter :isin_equals
  filter :name_contains
  filter :location
  filter :headquarter_location
  filter :size, as: :select, collection: Company::SIZES

  index do
    selectable_column
    column :name do |company|
      link_to company.name, admin_company_path(company)
    end
    column :isin
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
      f.input :size, as: :select, collection: Company::SIZES
    end

    f.actions
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
