ActiveAdmin.register AdminUser do
  config.comments = false

  menu priority: 2, parent: 'Administration'

  permit_params :email, :first_name, :last_name, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :full_name
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form html: {'data-controller' => 'check-modified'} do |f|
    f.semantic_errors(*f.object.errors.keys)

    tabs do
      tab :details do
        f.inputs do
          f.input :email
          f.input :first_name
          f.input :last_name

          if f.object.new_record?
            f.input :password
            f.input :password_confirmation
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
      update_method = attributes.first[:password].present? ? :update_attributes : :update_without_password
      object.send(update_method, *attributes)
    end
  end
end
