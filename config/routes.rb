Rails.application.routes.draw do
  # TPI
  resources :sectors, only: [:show, :index]
  resources :companies, only: [:show]

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: 'admin/dashboard#index'
end
