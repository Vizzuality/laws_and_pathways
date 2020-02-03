ActiveAdmin.register Testimonial do
  config.batch_actions = false

  decorate_with TestimonialDecorator

  menu priority: 8, parent: 'TPI'

  permit_params :quote, :author, :role

  filter :author
  filter :role

  index do
    column :author, &:author_link
    column :quote
    column :role
    actions
  end

  show title: proc { |t| t.author } do
    tabs do
      tab :details do
        attributes_table do
          row :author
          row :quote
          row :role
        end
      end
    end
    active_admin_comments
  end

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :author
      f.input :quote, as: :text
      f.input :role
    end

    f.actions
  end
end
