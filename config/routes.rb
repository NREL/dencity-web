Dencity::Application.routes.draw do
  root 'structures#index'

  resources :measure_descriptions
  resources :provenances

  devise_for :users
  resources :users
  get '/admin' => 'users#admin'

  devise_scope :user do
    get '/login' => 'devise/sessions#new'
    get '/logout' => 'devise/sessions#destroy'
  end

  resources :structures, shallow: true do
    member do
      get 'download_file'
    end

    resources :measure_instances
  end

  # route to get search results
  get 'search' => 'search#show'

  resources :metas, shallow: true do
    collection do
      post 'meta_upload'
    end
  end
  match 'api/meta_upload' => 'metas#meta_upload', via: :post
  match 'api/meta_batch_upload' => 'metas#meta_batch_upload', via: :post

  resources :units

  # APIs
  match 'api/structure' => 'api#structure', via: :post
  match 'api/analysis' => 'api#analysis', via: :post
  match 'api/related_file' => 'api#related_file', via: :post
  match 'api/search' => 'api#search', via: :post
end
