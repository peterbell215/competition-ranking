Rails.application.routes.draw do
  resources :teams do
    resources :exclusions, only: [:new, :create, :destroy]
  end

  devise_for :users
  resources :users

  # Defines the root path route ("/")
  root to: 'users#index'
end
