ActiveAdmin.register Testimonial do
  config.batch_actions = false

  decorate_with TestimonialDecorator

  menu priority: 7, parent: 'TPI'

  permit_params :quote, :author, :role, :avatar

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
          row :avatar do |t|
            image_tag(url_for(t.avatar)) if t.avatar.present?
          end
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
      f.input :avatar, as: :file
    end

    f.actions
  end
end
