ActiveAdmin::Devise::SessionsController.class_eval do
  def after_sign_out_path_for(_resource)
    '/'
  end
end
