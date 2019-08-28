ActiveAdmin.register CP::Assessment do
  config.sort_order = 'publication_date_desc'

  menu parent: 'TPI', priority: 2, label: 'Carbon Performance Assessments'

  decorate_with CP::AssessmentDecorator

  actions :all, except: [:new, :edit, :create, :update]

  filter :assessment_date
  filter :publication_date
  filter :company
  filter :company_sector_id, as: :select, collection: proc { Sector.all }

  data_export_sidebar 'CP Assessments'

  show do
    attributes_table do
      row :id
      row :company
      row :assessment_date
      row :publication_date
      row :assumptions
      row :created_at
      row :updated_at
    end

    panel 'Emissions/Targets' do
      render 'admin/cp/emissions_table', emissions: resource.emissions
    end
  end

  index do
    column :title, &:title_link
    column :assessment_date
    column :publication_date
    actions
  end

  controller do
    def scoped_collection
      super.includes(:company)
    end
  end
end
