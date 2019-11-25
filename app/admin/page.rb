ActiveAdmin.register Page do
  config.batch_actions = false

  menu priority: 6, parent: 'TPI'

  permit_params :title, :slug, :description, contents_attributes: permit_params_for(:contents), content_ids: []

  index do
    column :slug
    column :title
    column :description
    actions
  end

  show do
    tabs do
      tab :details do
        attributes_table do
          row :slug
          row :title
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
              column :text
            end
          end
        end
      end
    end

    active_admin_comments
  end

  form partial: 'form'
end
