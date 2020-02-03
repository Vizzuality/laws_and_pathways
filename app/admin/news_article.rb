ActiveAdmin.register NewsArticle do
  config.batch_actions = false
  config.sort_order = 'publication_date_desc'

  menu parent: 'TPI', priority: 8

  decorate_with NewsArticleDecorator

  permit_params :title, :content, :publication_date, :article_type,
                :created_by_id, :updated_by_id,
                :image, :keywords_string, tpi_sector_ids: []

  filter :title
  filter :content
  filter :publication_date

  show do
    tabs do
      tab :details do
        attributes_table do
          row :title
          row :article_type
          row :content
          row :publication_date
          list_row 'Sectors', :tpi_sector_links
          row 'Keywords', &:keywords_string
          row :image do |t|
            image_tag(url_for(t.image)) if t.image.present?
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
    column :article_type
    column :publication_date
    column :created_by
    column :updated_by

    actions
  end

  csv do
    column :id
    column :title
    column :article_type
    column :content
    column :publication_date
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :title
      f.input :article_type, as: :select, collection: array_to_select_collection(NewsArticle::ARTICLE_TYPES)
      f.input :content, as: :trix, embed_youtube: true
      f.input :publication_date
      f.input :tpi_sector_ids, label: 'Sectors', as: :select,
                               collection: TPISector.order(:name), input_html: {multiple: true}
      f.input :keywords_string, label: 'Keywords', hint: t('hint.tag'), as: :tags, collection: Keyword.pluck(:name)
      f.input :image, as: :file
    end

    f.actions
  end

  controller do
    def scoped_collection
      super.includes(:tpi_sectors, :keywords)
    end

    def apply_filtering(chain)
      super(chain).distinct
    end
  end
end
