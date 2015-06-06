Dencity::Application.routes.draw do
  root 'structures#index'

  resources :measure_descriptions
  resources :analyses do
    member do
      get 'buildings'
    end
  end

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
  match 'api/structure' => 'api#structure_v1', via: :post
  match 'api/analysis' => 'api#analysis_v1', via: :post
  match 'api/related_file' => 'api#related_file_v1', via: :post
  match 'api/search' => 'api#search_v1', via: :post
  match 'api/remove_file' => 'api#remove_file_v1', via: :post

  # v1
  match 'api/v1/structure' => 'api#structure_v1', via: :post
  match 'api/v1/analysis' => 'api#analysis_v1', via: :post
  match 'api/v1/related_file' => 'api#related_file_v1', via: :post
  match 'api/v1/search' => 'api#search_v1', via: :post
  match 'api/v1/remove_file' => 'api#remove_file_v1', via: :post
end
