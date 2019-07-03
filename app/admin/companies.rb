ActiveAdmin.register Company do
  permit_params :name, :isin, :sector_id, :location_id, :headquarter_location_id, :ca100,
                :size

  filter :isin_contains, label: 'ISIN'
  filter :name_contains, label: 'Name'
  filter :location
  filter :headquarter_location
  filter :size, as: :check_boxes, collection: array_to_select_collection(Company::SIZES)

  config.batch_actions = false

  index do
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
      columns do
        column { f.input :name  }
        column { f.input :isin, label: 'ISIN' }
      end

      columns do
        column { f.input :sector }
        column { f.input :size, as: :select, collection: array_to_select_collection(Company::SIZES) }
      end

      columns do
        column { f.input :location }
        column { f.input :headquarter_location }
      end

      f.input :ca100
    end

    f.actions
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
