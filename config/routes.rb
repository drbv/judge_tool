Rails.application.routes.draw do

  get 'admin/utilities/index'
  post 'admin/utilities/db_upload'
  get 'admin/utilities/judge_tool_reset'


  namespace :admin do
    resources :users do
      collection do
      end
    end
    resources :rounds do
      member do
        post :start
        delete :close
        get :download_ratings
      end
    end
  end
  namespace :judges do
    resource :dance_round do
      post :accept
    end
    scope ':user_id' do
      resources :dance_rounds, only: %w() do
        member do
          get :status
        end
      end
    end
  end

  get '/admin/rounds/:dance_round_id/:dance_team_id', to: 'admin/rounds#repeat', as: :admin_repeat_dance_round
  get '/admin/dance_rounds/:dance_round_id/:dance_team_id', to: 'admin/dance_rounds#show_dance_team', as: :admin_show_dance_team_dance_round
  patch '/admin/dance_rounds/update_dance_round_rating/:id', to: 'admin/dance_rounds#update_dance_round_rating', as: :update_dance_round_rating

  resource :round, only: %i(show)
  resource :dance_round, only: %i(show)
  resources :pages, only: :show
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  root to: 'rounds#index'
end
