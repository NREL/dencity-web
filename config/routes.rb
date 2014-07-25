Dencity::Application.routes.draw do

  resources :measure_instances

  resources :measure_descriptions

  resources :provenances

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
  end

  resources :metas, shallow: true do
    collection do
      post 'meta_upload'
    end
  end
  match 'api/meta_upload' => 'metas#meta_upload', via: :post
  match 'api/meta_batch_upload' => 'metas#meta_batch_upload', via: :post

  resources :units

end
