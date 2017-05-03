Rails.application.routes.draw do

  # Routes for main resources
  resources :items
  resources :purchases
  resources :item_prices
  resources :users
  resources :schools
  resources :orders
  resources :sessions

  # Authentication routes
  get 'user/edit' => 'users#edit', as: :edit_current_user
  get 'signup' => 'users#new', as: :signup
  get 'logout' => 'sessions#destroy', as: :logout
  get 'login' => 'sessions#new', as: :login

  # Semi-static page routes
  get 'home' => 'home#home', as: :home
  get 'about' => 'home#about', as: :about
  get 'contact' => 'home#contact', as: :contact
  get 'privacy' => 'home#privacy', as: :privacy

  # Routes for cart
  post 'add_item/:id' => 'items#add_item', :as => :add_item
  post 'remove_item/:id' => 'items#remove_item', :as => :remove_item
  post 'empty_cart' => 'orders#empty_cart', :as => :empty_cart
  get 'cart' => 'orders#cart', :as => :cart
  get 'checkout' => 'orders#checkout', :as => :checkout

  # Routes for user
  get 'dashboard' => 'users#dashboard', as: :dashboard

  # Set the root url
  root :to => 'home#home'

end
