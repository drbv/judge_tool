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
  end

  resource :round, only: %i(show)
  resources :pages, only: :show
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  root to: 'rounds#index'
end
