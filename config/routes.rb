Rails.application.routes.draw do
  namespace :tpi do
    resources :sectors, only: [:show, :index] do
      collection do
        get :levels_chart_data
        get :benchmarks_chart_data
      end
      member do
        get :levels_chart_data
        get :emissions_chart_data
      end
    end
    resources :companies, only: [:show] do
      member do
        get :emissions_chart_data
        get :assessments_levels_chart_data
      end
    end
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: 'admin/dashboard#index'
end
