ActiveAdmin.register NewsArticle do
  config.batch_actions = false
  config.sort_order = 'publication_date_desc'

  menu parent: 'TPI', priority: 9

  decorate_with NewsArticleDecorator

  permit_params :title, :content, :publication_date, :is_insight,
                :created_by_id, :updated_by_id, :short_description,
                :image, :keywords_string, tpi_sector_ids: []

  filter :title
  filter :content
  filter :short_description
  filter :publication_date

  action_item :preview, priority: 0, only: :show do
    link_to 'Preview', resource.preview_url
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :title
          row :short_description
          row :content
          row :publication_date
          list_row 'Sectors', :tpi_sector_links
          row 'Keywords', &:keywords_string
          row :image do |t|
            image_tag(url_for(t.image)) if t.image.present?
          end
          row :is_insight
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
    column :is_insight

    actions
  end

  csv do
    column :id
    column :title
    column :short_description
    column :content
    column(:sectors) { |l| l.tpi_sectors.map(&:name).join(Rails.application.config.csv_options[:entity_sep]) }
    column :keywords, &:keywords_csv
    column :publication_date
    column :is_insight
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs do
      f.input :title
      f.input :short_description, as: :text
      f.input :content, as: :trix, embed_youtube: true
      f.input :publication_date, as: :date_time_picker
      f.input :tpi_sector_ids, label: 'Sectors', as: :select,
                               collection: TPISector.order(:name), input_html: {multiple: true}
      f.input :keywords_string, label: 'Keywords', hint: t('hint.tag'), as: :tags, collection: Keyword.pluck(:name)
      f.input :image, as: :file, input_html: {accept: 'image/*'}
      f.input :is_insight
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
