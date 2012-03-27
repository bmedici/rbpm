Rbpm::Application.routes.draw do

  resources :systems do
    member do
      get :update_status
    end
  end

  resources :workers

  resources :steps
  resources :links  
  resources :jobs do
    member do
      get :reset
    end
  end
  
  resources :actions
  # See https://gist.github.com/1713398 for a more generic method
  
  # Dynamically create resources for Steps
  STEP_CLASSES.each do |class_name|
    resource_name = class_name.underscore.pluralize.to_sym
    resources resource_name, :controller => :steps
  end
  
  # Dynamically create resources for Links
  LINK_CLASSES.each do |class_name|
    resource_name = class_name.underscore.pluralize.to_sym
    resources resource_name, :controller => :links
  end

  get "webservice/getdate"
  get "webservice/wait"
  get "webservice/encode"
  get "webservice/checksum"

  get "graph/map/:id" => "graph#map", :as => :map_graph
  get "graph/job/:id" => "graph#job", :as => :job_graph
  get "status/dashboard" => "status#dashboard", :as => :dashboard
  get "status/workflows" => "status#workflows", :as => :workflows
  get "status/editor" => "status#editor", :as => :workflow_editor
  get "monitor" => "status#monitor", :as => :monitor

  get "status/ajax_workers" => "status#ajax_workers", :as => :ajax_workers
  get "status/ajax_jobs" => "status#ajax_jobs", :as => :ajax_jobs
  get "status/ajax_system/:id" => "status#ajax_system", :as => :ajax_system

  root :to => 'status#workflows'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (map { |e|  }s HTTP verbs to controller actions automatically):
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
  #     resources :sales do  #       get 'recent', :on => :collection
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
end
