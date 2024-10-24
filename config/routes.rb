Rails.application.routes.draw do
  get 'robots.:format' => 'robots#index'

  constraints DomainConstraint.new(Rails.configuration.tpi_domain) do
    scope module: 'tpi', as: 'tpi' do
      root to: 'home#index'

      # maybe temporary redirects to remove /tpi part
      get '/tpi', to: redirect('/')
      get '/tpi/*rest', to: redirect('%{rest}')

      get '/newsletter', to: 'home#newsletter'

      get '/sandbox', to: 'home#sandbox' if Rails.env.development?

      get '/search', to: 'search#index'
      get '/sitemap', to: 'sitemaps#index'

      get '/corporate-bond-issuers', to: 'home#corporate_bond_issuers'

      resources :sectors, only: [:show, :index] do
        collection do
          get :levels_chart_data
          get :cp_performance_chart_data
          get :user_download_all
          get :user_download_methodology
          post :send_download_file_info_email
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

      resources :banks, only: [:show, :index] do
        member do
          get :emissions_chart_data
          get :cp_matrix_data
          get :assessment
        end
        collection do
          get :index_assessment
          get :average_bank_score_chart_data
          get :user_download
        end
      end

      resources :ascor, only: [:show, :index] do
        member do
          get :show_assessment
        end
        collection do
          get :index_assessment
          get :index_emissions_assessment
          get :emissions_chart_data
          get :user_download
        end
      end

      resources :publications, only: [:index, :show] do
        member do
          get :show_news_article
        end
        collection do
          get :partial
        end
      end
      get '/publications/uploads/:slug', to: 'publications#download_file', as: :publication_download_file

      resources :mq_assessments, only: [:show] do
        collection do
          get :enable_beta_data
          get :disable_beta_data
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

      get '/sitemap', to: 'sitemaps#index'

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
