ActiveAdmin.register AdminUser do
  config.comments = false

  menu priority: 2, parent: 'Administration'

  decorate_with AdminUserDecorator

  permit_params :email, :first_name, :last_name, :role, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :gravatar
    column :email
    column :full_name
    column :role
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :first_name
      row :last_name
      row :full_name
      row :role
      row :gravatar
      row :updated_at
      row :created_at
    end

    active_admin_comments
  end

  filter :email
  filter :role, as: :select, label: 'User Role', collection: proc { AdminUser::ROLES }

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    tabs do
      tab :details do
        f.inputs do
          f.input :email
          f.input :first_name
          f.input :last_name
          f.input :role,
                  as: :select,
                  collection: array_to_select_collection(AdminUser::ROLES, :to_s)

          if f.object.new_record?
            f.input :password
            f.input :password_confirmation
          else
            li class: 'input' do
              label :gravatar
              img src: f.object.gravatar_url
            end
          end
        end
      end

      unless f.object.new_record?
        tab :change_password do
          f.inputs do
            f.input :password
            f.input :password_confirmation
          end
        end
      end
    end

    f.actions
  end

  controller do
    # update without password if not provided
    def update_resource(object, attributes)
      update_method = attributes.first[:password].present? ? :update : :update_without_password

      object.send(update_method, *attributes)
    end
  end
end
