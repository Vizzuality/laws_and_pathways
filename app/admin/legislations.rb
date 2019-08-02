ActiveAdmin.register Legislation do
  config.sort_order = 'date_passed_desc'

  menu parent: 'Laws', priority: 1

  decorate_with LegislationDecorator

  scope('All', &:all)
  scope('Draft', &:draft)
  scope('Published', &:published)
  scope('Archived', &:archived)

  permit_params :title, :date_passed, :description,
                :framework, :location_id, :law_id,
                :visibility_status, document_type_ids: []

  filter :title_contains, label: 'Title'
  filter :date_passed
  filter :description_contains, label: 'Description'
  filter :location
  filter :framework,
         as: :select,
         collection: array_to_select_collection(Legislation::FRAMEWORKS)

  config.batch_actions = false

  index do
    column :title, &:title_summary_link
    column :date_passed
    column :framework
    column :location
    column :document_types
    tag_column :visibility_status

    actions
  end

  sidebar 'Publishing Status', only: :show do
    attributes_table do
      tag_row :visibility_status, interactive: true
    end
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :title
          row :description
          row :date_passed
          row :location
          row :law_id
          row :framework
          row :created_at
          row :updated_at
          row :document_type_links
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

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :title
      f.input :description, as: :trix
      f.input :law_id
      f.input :document_type_ids,
              label: 'Document Types',
              as: :tags,
              collection: DocumentType.all
      columns do
        column { f.input :location }
        column { f.input :date_passed }
        column do
          f.input :framework,
                  as: :select,
                  collection: array_to_select_collection(Legislation::FRAMEWORKS)
        end
      end
    end

    f.actions
  end

  csv do
    column :law_id
    column :title
    column :date_passed
    column :description
    column :framework
    column(:location) { |legislation| legislation.location.name }
    column(:document_types) { |legislation| legislation.document_types.map(&:name).join(' / ') }
  end

  controller do
    def scoped_collection
      super.includes(:location, :document_types)
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
