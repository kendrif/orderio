require 'sidekiq/web'

Rails.application.routes.draw do

  resources :orders do
    member do 
      patch :complete 
    end
  end

  resources :products do
    member do 
      patch :available 
    end
  end

  resources :categories do
    member do 
      patch :available 
    end
  end

  resources :categories
  get 'users/show'
  get 'admin/index'
  get 'admin/order'
  get 'admin/edit'
  get 'admin/products'
  get 'admin/orderarchive'
  get 'admin/landingpage'

  get '/start', to: 'admin#landingpage'
  get '/sales', to: 'admin#sales'

  get "menu/:id" => "store#menu", as: :menu

  get '' => 'store#profile', constraints: {subdomain: /.+/}

  resources :store
  resources :line_items
  resources :carts
  get 'store/index'
  resources :products
  
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :projects do
    resources :comments, module: :projects
  end

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" } 

  resource :subscription

  root to: 'admin#landingpage'

end