Dencity::Application.routes.draw do
  apipie
  root 'structures#index'

  resources :measure_descriptions
  resources :analyses do
    member do
      get 'buildings'
    end
  end
  get '/retrieve_analysis' => 'analyses#retrieve_analysis'

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

  resources :metas, shallow: true 
 
  resources :units

=begin
  # APIs (default routes)
  match 'api/structure' => 'api#structure_v1', via: :post
  match 'api/analysis' => 'api#analysis_v1', via: :post
  match 'api/related_file' => 'api#related_file_v1', via: :post
  match 'api/search' => 'api#search_v1', via: :post
  match 'api/remove_file' => 'api#remove_file_v1', via: :post
  match 'api/meta_upload' => 'metas#meta_upload_v1', via: :post
  match 'api/meta_batch_upload' => 'metas#meta_batch_upload_v1', via: :post

  # API v1
  match 'api/v1/structure' => 'api#structure_v1', via: :post
  match 'api/v1/analysis' => 'api#analysis_v1', via: :post
  match 'api/v1/related_file' => 'api#related_file_v1', via: :post
  match 'api/v1/search' => 'api#search_v1', via: :post
  match 'api/v1/remove_file' => 'api#remove_file_v1', via: :post
  match 'api/v1/meta_upload' => 'metas#meta_upload_v1', via: :post
  match 'api/v1/meta_batch_upload' => 'metas#meta_batch_upload_v1', via: :post
=end

  namespace :api do
    namespace :v1 do

      post 'structure' => 'api#structure'
      post 'analysis' => 'api#analysis'
      post 'related_file' => 'api#related_file'
      post 'remove_file' => 'api#remove_file'
      post 'search' => 'api#search'
      post 'meta_upload' => 'api#meta_upload'
      post 'meta_batch_upload' => 'api#meta_batch_upload'

    end
    # match all api requests w/o version numbers to v1
    post 'structure' => 'v1/api#structure'
    post 'analysis' => 'v1/api#analysis'
    post 'related_file' => 'v1/api#related_file'
    post 'remove_file' => 'v1/api#remove_file'
    post 'search' => 'v1/api#search'
    post 'meta_upload' => 'v1/api#meta_upload'
    post 'meta_batch_upload' => 'api#meta_batch_upload'
  end

end
