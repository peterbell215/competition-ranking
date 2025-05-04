Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions"
  }
  resources :users

  resources :teams do
    resources :exclusions, only: [:new, :create, :destroy]
  end


  resources :rankings, only: [:index] do
    collection do
      patch :update_rankings
    end
  end
  
  resources :results, only: [:index]

  # Defines the root path route ("/")
  root to: "rankings#index"
end
