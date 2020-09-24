Rails.application.routes.draw do
  constraints DomainConstraint.new(Rails.configuration.tpi_domain) do
    scope module: 'tpi', as: 'tpi' do
      root to: 'home#index'

      # maybe temporary redirects to remove /tpi part
      get '/tpi', to: redirect('/')
      get '/tpi/*rest', to: redirect('%{rest}')

      get '/about', to: 'home#about'
      get '/newsletter', to: 'home#newsletter'
      get '/register', to: 'home#register'

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
    end
  end

  constraints DomainConstraint.new(Rails.configuration.cclow_domain) do
    scope module: 'cclow', as: 'cclow' do
      root to: 'home#index'

      # maybe temporary redirects to remove /cclow part
      get '/cclow', to: redirect('/')
      get '/cclow/api/targets', to: 'api/targets#index'
      get '/cclow/api/targets/economy-wide-countries', to: 'api/targets#economy_wide_countries'
      get '/cclow/api/targets/:iso', to: 'api/targets#show'
      get '/cclow/*rest', to: redirect('%{rest}')

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
        get 'targets/economy-wide-countries', to: 'targets#economy_wide_countries'
        get 'targets/:iso', to: 'targets#show'
      end
    end
  end

  DynamicRouter.load

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
end
