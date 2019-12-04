Rails.application.routes.draw do
  namespace :tpi do
    root to: 'home#index'

    get '/about', to: 'home#about'
    get '/newsletter', to: 'home#newsletter'
    get '/register', to: 'home#register'
    get '/disclaimer', to: 'home#disclaimer'
    get '/sandbox', to: 'home#sandbox' if Rails.env.development?

    resources :sectors, only: [:show, :index] do
      collection do
        get :levels_chart_data
        get :cp_performance_chart_data
        get :user_download_all
      end
      member do
        get :levels_chart_data
        get :emissions_chart_data
        get :user_download
      end
    end

    resources :companies, only: [:show] do
      member do
        get :emissions_chart_data
        get :assessments_levels_chart_data
        get :mq_assessment
        get :cp_assessment
        get :user_download
      end
    end

    resources :publications, only: [:index, :show]
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

  root to: 'tpi/home#index'
end
