ActiveAdmin.register Publication do
  config.batch_actions = false
  config.sort_order = 'publication_date_desc'

  menu parent: 'TPI', priority: 8

  decorate_with PublicationDecorator

  permit_params :title, :short_description, :publication_date,
                :file, :thumbnail, :created_by_id, :updated_by_id

  filter :title
  filter :short_description
  filter :publication_date

  show do
    tabs do
      tab :details do
        attributes_table do
          row :title
          row :short_description
          row :publication_date
          row :thumbnail do |t|
            image_tag(url_for(t.thumbnail)) if t.thumbnail.present?
          end
          row :file do |t|
            link_to t.file
          end
          row :updated_at
          row :updated_by
          row :created_at
          row :created_by
        end
      end
    end
    active_admin_comments
  end

  index do
    column 'Title', :title_link
    column :short_description
    column :publication_date
    column :created_by
    column :updated_by

    actions
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :title
      f.input :short_description, as: :text
      f.input :publication_date
      f.input :file, as: :file
      f.input :thumbnail, as: :file
    end

    f.actions
  end

  controller do
    include DiscardableController

    def scoped_collection
      super
    end

    def apply_filtering(chain)
      super(chain).distinct
    end
  end
end
