ActiveAdmin.register Publication do
  config.batch_actions = false
  config.sort_order = 'publication_date_desc'

  menu parent: 'TPI', priority: 11

  decorate_with PublicationDecorator

  permit_params :title, :author, :author_image, :short_description, :publication_date,
                :file, :image, :created_by_id, :updated_by_id,
                :keywords_string, tpi_sector_ids: []

  filter :title
  filter :short_description
  filter :publication_date

  show do
    tabs do
      tab :details do
        attributes_table do
          row :title
          row :short_description
          row :author
          row :author_image do |p|
            if p.author_image.present?
              image_tag(
                url_for(p.author_image_thumbnail),
                style: 'width:40px;height:40px;border-radius: 50%;'
              )
            end
          end
          row :publication_date
          list_row 'Sectors', :tpi_sector_links
          row 'Keywords', &:keywords_string
          row :image do |t|
            image_tag(url_for(t.image)) if t.image.present?
          end
          row :file, &:file_link
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
    column :file, &:file_link
    column :short_description
    column :publication_date

    actions
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :title
      f.input :author
      f.input :author_image, as: :file, hint: preview_file_tag(f.object.author_image), input_html: {accept: 'image/*'}
      f.input :short_description, as: :text
      f.input :publication_date, as: :date_time_picker
      f.input :tpi_sector_ids, label: 'Sectors', as: :select,
                               collection: TPISector.order(:name), input_html: {multiple: true}
      f.input :keywords_string, label: 'Keywords', hint: t('hint.tag'), as: :tags, collection: Keyword.pluck(:name)
      f.input :file,
              as: :file,
              hint: preview_file_tag(f.object.file),
              input_html: {
                accept: 'application/pdf, application/vnd.ms-powerpoint, .ppt, .pptx, application/msword, .docx'
              }
      f.input :image, as: :file, hint: preview_file_tag(f.object.image), input_html: {accept: 'image/*'}
    end

    f.actions
  end

  controller do
    def scoped_collection
      super.includes(:tpi_sectors)
    end

    def apply_filtering(chain)
      super(chain).distinct
    end
  end
end
