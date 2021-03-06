Fha2::Application.routes.draw do
  # root :to => "todos#index"
  match 'api/fha_sec223f_demo' => 'todos#index'
  
  namespace :api do
    match 'fha_overview' => 'beta1/documentation#fha_overview', :via => :get
    namespace :beta1 do
      match 'sec223f_acquisition' => 'sec223f_acquisition#loan', :via => :post
      match 'sec223f_refinance' => 'sec223f_refinance#loan', :via => :post

      resources :api_keys, :only=>[:new, :show, :create]

      # match 'documentation/sec223f' => 'documentation#sec223f', :via => :get
      match 'documentation/sec223f_acquisition' => 'documentation#sec223f_acquisition', :via => :get
      match 'documentation/sec223f_refinance' => 'documentation#sec223f_refinance', :via => :get
    end
  end
  
  match "*path" => "api/beta1/documentation#catch_all"
  
  root :to => "api/beta1/documentation#home"
    
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
  # https://github.com/bradphelan/jasminerice
  # if ["development", "test"].include? Rails.env
  #     mount Jasminerice::Engine => "/jasmine" 
  # end
end
