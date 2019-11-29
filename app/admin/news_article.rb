ActiveAdmin.register NewsArticle do
  config.batch_actions = false
  config.sort_order = 'publication_date_desc'

  menu parent: 'TPI', priority: 7

  decorate_with NewsArticleDecorator

  permit_params :title, :content, :publication_date,
                :created_by_id, :updated_by_id

  filter :title
  filter :content
  filter :publication_date

  show do
    tabs do
      tab :details do
        attributes_table do
          row :title
          row :content
          row :publication_date
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
    column :content
    column :publication_date
    column :created_by
    column :updated_by

    actions
  end

  csv do
    column :id
    column :title
    column :content
    column :publication_date
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :title
      f.input :content, as: :trix
      f.input :publication_date
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

    def csv_format?
      request[:format] == 'csv'
    end
  end
end
