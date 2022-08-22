ActiveAdmin.register CaseStudy do
  config.batch_actions = false

  menu priority: 10, parent: 'TPI'

  decorate_with CaseStudyDecorator

  permit_params :organization, :text, :link, :logo

  filter :organization

  index do
    column :logo
    column :organization, &:organization_link
    column :text
    column :link
    actions
  end

  show title: proc { |t| t.organization } do
    tabs do
      tab :details do
        attributes_table do
          row :logo
          row :organization
          row :link
          row :text
        end
      end
    end
    active_admin_comments
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :organization
      f.input :link
      f.input :logo
      f.input :text, as: :text
    end

    f.actions
  end
end
