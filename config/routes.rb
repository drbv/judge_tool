Rails.application.routes.draw do

  get 'tournament/utilities/index'
  post 'tournament/utilities/db_upload'
  get 'tournament/utilities/judge_tool_reset'


  namespace :tournament do
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

  get '/tournament/rounds/:dance_round_id/:dance_team_id', to: 'tournament/rounds#repeat', as: :tournament_repeat_dance_round

  resource :round, only: %i(show)
  resource :dance_round, only: %i(show)
  resources :pages, only: :show
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  root to: 'rounds#index'
end
