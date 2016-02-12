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
    scope ':dance_team_id' do
      resources :dance_rounds, only: :show
    end
    resources :ratings, only: :update
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

  post '/admin/rounds/:dance_round_id/:dance_team_id', to: 'admin/rounds#repeat', as: :admin_repeat_dance_round

  resource :round, only: %i(show)
  resource :dance_round, only: %i(show)
  resources :pages, only: :show
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  root to: 'rounds#index'
end
