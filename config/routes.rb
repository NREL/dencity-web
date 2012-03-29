Bemscape::Application.routes.draw do

  devise_for :users , :path_prefix => 'd' do
    get "/logout" => "devise/sessions#destroy"
    get "/login" => "devise/sessions#new"
    get "/register" => "devise/registrations#new"
    
  end
  resources :users
  resources :inputs, :except => [:new, :edit, :update, :create, :show, :index, :destroy] do
    get :inputs, :on => :collection
    post :process_inputs, :on => :collection
  end

  resources :api_keys, :only => [:create, :destroy]

  match "/edifices/location" => "edifices#location"
  resources :edifices do
    get :location, :on => :collection
    get :get_data, :on => :collection
    get :download, :on => :collection
  end
  
  resources :apis do
    post :submit_building_v1
    get :retrieve_building_v1
    get :list_descriptors_v1
    post :submit_preprocessor_v1
    put :update_building_v1
  end
  
  root :to => 'edifices#home'
  
  match "get_data" => "edifices#get_data"

  #API - current version (will change when new version is released)
  match "/api/submit_building" => "apis#submit_building_v1"
  match "/api/retrieve_building" => "apis#retrieve_building_v1"
  match "/api/list_descriptors" => "apis#list_descriptors_v1"
  match "/api/update_building" => "apis#update_building_v1"
  
  #API - version1
  match "/api/v1/submit_building" => "apis#submit_building_v1"
  match "/api/v1/retrieve_building" => "apis#retrieve_building_v1"
  match "/api/v1/list_descriptors" => "apis#list_descriptors_v1"
  match "/api/v1/update_building" => "apis#update_building_v1"
  
  #API - preprocessor
  match "/api/preprocessor/submit" => "apis#submit_preprocessor_v1"
  
  #input form
  match "inputs" => "inputs#inputs"
  match "results" => "inputs#process_inputs"
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
