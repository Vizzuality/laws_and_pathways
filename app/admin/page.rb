ActiveAdmin.register Page do
  config.batch_actions = false

  decorate_with PageDecorator

  menu priority: 6, parent: 'TPI'

  permit_params :title, :slug, :description, :menu,
                contents_attributes: [:id, :title, :content_type, :text, :_destroy,
                                      images_attributes: [:id, :link, :logo, :_destroy]],
                content_ids: []

  filter :title
  filter :slug

  index do
    column :slug
    column :title
    column :menu
    actions
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :slug
          row :title
          row :menu
          row :description
        end
      end

      tab :contents do
        panel 'Contents' do
          if resource.contents.empty?
            div class: 'padding-20' do
              'No Contents added'
            end
          else
            table_for resource.contents do
              column :title
              column :content_type
              column :text
              column :images do |content|
                if content.images.any?
                  span do
                    content.images.count
                  end
                  span do
                    'images. Click "Edit" to browse through them.'
                  end
                else
                  'No images attached'
                end
              end
            end
          end
        end
      end
    end

    active_admin_comments
  end

  form partial: 'form'
end
