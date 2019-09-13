Rails.application.routes.draw do
  get 'companies/show'
  get 'sectors/index'
  get 'sectors/show'
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: 'admin/dashboard#index'
end
