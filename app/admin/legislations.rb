ActiveAdmin.register Legislation do
  config.sort_order = 'date_passed_desc'

  menu parent: 'Laws', priority: 1

  decorate_with LegislationDecorator

  publishable_scopes

  permit_params :title, :date_passed, :description,
                :geography_id, :law_id,
                :natural_hazards_string, :keywords_string,
                :created_by_id, :updated_by_id,
                :visibility_status, framework_ids: [], document_type_ids: [],
                                    documents_attributes: [
                                      :id, :_destroy, :name, :language, :external_url, :type, :file
                                    ]

  filter :title_contains, label: 'Title'
  filter :date_passed
  filter :description_contains, label: 'Description'
  filter :geography
  filter :frameworks,
         as: :check_boxes,
         collection: proc { Framework.all }

  config.batch_actions = false

  index do
    column :title, &:title_summary_link
    column :date_passed
    column 'Frameworks', &:frameworks_string
    column :geography
    column :document_types
    column :created_by
    column :updated_by
    tag_column :visibility_status

    actions
  end

  publishable_sidebar only: :show

  show do
    tabs do
      tab :details do
        attributes_table do
          row :title
          row :description
          row :date_passed
          row :geography
          row :law_id
          row 'Frameworks', &:frameworks_string
          row :updated_at
          row :updated_by
          row :created_at
          row :created_by
          row 'Document Types', &:document_types_string
          row 'Keywords', &:keywords_string
          row 'Natural Hazards', &:natural_hazards_string
          list_row 'Documents', :document_links
        end
      end

      tab :litigations do
        panel 'Connected Litigations' do
          if resource.litigations.empty?
            div class: 'padding-20' do
              'No Litigations are connected with this legislation'
            end
          else
            table_for resource.litigations.decorate do
              column :title, &:title_link
              column :document_type
            end
          end
        end
      end
    end
  end

  form partial: 'form'

  csv do
    column :law_id
    column :title
    column :date_passed
    column :description
    column(:frameworks) { |legislation| legislation.frameworks.map(&:name).join(';') }
    column(:geography) { |legislation| legislation.geography.name }
    column(:document_types) { |legislation| legislation.document_types.map(&:name).join(';') }
  end

  controller do
    def scoped_collection
      super.includes(:geography, :frameworks, :document_types)
    end
  end
end
