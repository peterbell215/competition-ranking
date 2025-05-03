Rails.application.routes.draw do
  resources :teams do
    resources :exclusions, only: [:new, :create, :destroy]
  end

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  resources :users

  # Defines the root path route ("/")
  root to: 'home#index'
end
