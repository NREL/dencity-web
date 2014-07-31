Dencity::Application.routes.draw do

  resources :measure_descriptions

  resources :provenances
  #match 'api/add_provenance' => 'provenances#add_provenance', via: :post

  devise_for :users
  resources :users
  get '/admin' => 'users#admin'

  devise_scope :user do
    get '/login' => 'devise/sessions#new'
    get '/logout' => 'devise/sessions#destroy'
  end

  root 'metas#index'

  resources :structures  do
    resources :attachments
    resources :measure_instances
  end
  #match 'api/add_structure' => 'structures#add_structure', via: :post

  resources :metas, shallow: true do
    collection do
      post 'meta_upload'
    end
  end
  match 'api/meta_upload' => 'metas#meta_upload', via: :post
  match 'api/meta_batch_upload' => 'metas#meta_batch_upload', via: :post

  resources :units

  match 'api/structure' => 'api#structure', via: :post
  match 'api/structure_metadata' => 'api#structure_metadata', via: :post

end
