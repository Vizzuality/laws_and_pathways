Rails.application.routes.draw do
  namespace :tpi do
    root to: 'home#index'

    get '/about', to: 'home#about'
    get '/newsletter', to: 'home#newsletter'
    get '/register', to: 'home#register'
    get '/disclaimer', to: 'home#disclaimer'
    get '/sandbox', to: 'home#sandbox' if Rails.env.development?

    get '/search', to: 'search#index'

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

    resources :publications, only: [:index, :show] do
      collection do
        get :partial
      end
    end
    DynamicRouter.load
  end

  namespace :cclow do
    root to: 'home#index'
    get '/sandbox', to: 'home#sandbox' if Rails.env.development?

    resources :geographies, only: [:show] do
      resources :laws, controller: 'geography/legislations', only: [:show, :index], defaults: {scope: :laws}
      resources :policies, controller: 'geography/legislations', only: [:show, :index], defaults: {scope: :policies}
      resources :litigation_cases, controller: 'geography/litigation_cases', only: [:show, :index]
      resources :climate_targets, controller: 'geography/climate_targets', only: [:index]
      get 'climate_targets/:law_sector',
          to: 'geography/climate_targets#laws_sector',
          as: :geography_climate_targets_sector
    end

    resources :climate_targets, only: :index
    resources :legislation_and_policies, only: :index
    resources :litigation_cases, only: :index

    namespace :api do
      resources :map_indicators, only: :index
      get :search, to: 'search#index'
      get :search_counts, to: 'search#counts'
      get 'targets', to: 'targets#index'
      get 'targets/:iso', to: 'targets#show'
    end
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: 'tpi/home#index', constraints: lambda { |req| ['transitionpathwayinitiative.org', 'www.transitionpathwayinitiative.org'].include?(req.host) }, as: nil
  # root to: 'tpi/home#index', constraints: { host: ['transitionpathwayinitiative.org', 'www.transitionpathwayinitiative.org'] }, as: nil
  root to: 'cclow/home#index', constraints: lambda { |req| ['www.climate-laws.org', 'climate-laws.org'].include?(req.host) }, as: nil
  # root to: 'cclow/home#index', constraints: { host: ['www.climate-laws.org', 'climate-laws.org'] }, as: nil
  root to: 'admin/dashboard#index', constraints: { host: 'laws-pathways.vizzuality.com' }, as: nil
  root to: 'admin/dashboard#index', constraints: { host: 'laws-pathways-staging.vizzuality.com' }, as: nil
  root to: 'cclow/home#index'
end
