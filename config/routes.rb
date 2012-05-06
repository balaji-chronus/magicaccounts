Magicaccounts::Application.routes.draw do  
  controller :reports do
    get 'reports' => :index
    get "spend_by_category" => "reports#spend_by_category"
    get "spend_by_account" => "reports#spend_by_account"
    get "spend_by_user" => "reports#spend_by_user"
    get "transaction_count_by_category" => "reports#transaction_count_by_category"
    get "transaction_count_by_account" => "reports#transaction_count_by_account"
    get "avg_spend_by_category" => "reports#avg_spend_by_category"
    get "avg_spend_by_account" => "reports#avg_spend_by_account"
  end

  resources :comments

  root :to => 'transactions#user_profile'
  match 'groups/:code/adduser' => 'groups#adduser'
  match 'transactions/new/:accountid' => 'transactions#new'
  match 'profile' => "transactions#user_profile"
  match 'accounts/new/:groupid' => 'accounts#new'
  match 'groups/sendinvites' => 'groups#sendinvites'

  controller :sessions do
    get   'login' => :new
    post  'login' => :create
    get   'logout' => :destroy
  end

  resources :groups do
    resources :comments
  end

  resources :transactions do
    resources :comments
  end

  resources :accounts do
    resources :comments
  end
  
  resources :users

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
  
end
