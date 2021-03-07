%w[
  TPIPage
  CCLOWPage
].each do |page_class|
  ActiveAdmin.register page_class.constantize do
    config.batch_actions = false

    decorate_with PageDecorator

    menu priority: (page_class == 'TPIPage' ? 7 : 6),
         parent: (page_class == 'TPIPage' ? 'TPI' : 'Laws')

    permit_params :title, :slug, :description, :menu,
                  contents_attributes: [
                    *permit_params_for(:contents),
                    images_attributes: permit_params_for(:images)
                  ],
                  content_ids: []

    filter :title
    filter :slug

    index do
      column :title, &:title_link
      column :slug
      column :menu
      actions
    end

    action_item :preview, priority: 0, only: :show do
      link_to 'Preview', resource.preview_url
    end

    show do
      tabs do
        tab :details do
          attributes_table do
            row :title
            row :slug
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
              table_for resource.contents.decorate, id: 'page_show_contents_table' do
                orderable_handle_column name: 'Order', url: :sort_admin_content_path if current_user.can?(:update, resource)
                column :title
                column :content_type
                column :text, &:text_html
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

    form partial: 'admin/pages/form'
  end
end
