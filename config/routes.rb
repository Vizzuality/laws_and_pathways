Rails.application.routes.draw do
  namespace :tpi do
    root to: 'home#index'

    get '/about', to: 'home#about'
    get '/sandbox', to: 'home#sandbox' if Rails.env.development?

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
        get :mq_assessment
        get :cp_assessment
      end
    end

    resources :publications, only: :index
    DynamicRouter.load
  end

  namespace :cclow do
    root to: 'home#index'

    resources :geographies, only: [:show] do
      resources :laws, controller: 'geography/legislations', only: [:show, :index], defaults: { scope: :laws }
      resources :policies, controller: 'geography/legislations', only: [:show, :index], defaults: { scope: :policies }
      resources :litigation_cases, controller: 'geography/litigation_cases', only: [:show, :index]
      resources :climate_targets, controller: 'geography/climate_targets', only: [:show, :index]
    end

    resources :climate_targets, only: :index
    resources :legislation_and_policies, only: :index
    resources :litigation_cases, only: :index
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: 'admin/dashboard#index'
end
