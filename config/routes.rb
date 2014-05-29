Dencity::Application.routes.draw do
  devise_for :users
  resources :users
  get '/admin' => 'users#admin'

  devise_scope :user do
    get '/login' => 'devise/sessions#new'
    get '/logout' => 'devise/sessions#destroy'
  end

  root 'metas#index'

  resources :structures

  resources :metas, shallow: true do
    collection do
      post 'meta_upload'
    end
  end
  match 'api/meta_upload' => 'metas#meta_upload', via: :post
  match 'api/meta_batch_upload' => 'metas#meta_batch_upload', via: :post

  resources :units
=begin
  namespace :api do
    namespace :v1 do
      resources :structures do
        post 'meta'
        get 'meta'
      end
    end

  end
=end


end
