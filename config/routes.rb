Magicaccounts::Application.routes.draw do   
  match '/auth/:provider/callback' => 'authentications#create'
  
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
  resources :authentications
  root :to => 'users#dashboard'
  match 'groups/:code/adduser' => 'groups#adduser'
  match 'transactions/new/:groupid' => 'transactions#new'
  match 'profile' => "transactions#user_profile"
  match 'groups/sendinvites' => 'groups#sendinvites'

  controller :sessions do
    get   'login' => :new
    post  'login' => :create
    get   'logout' => :destroy
  end

  resources :groups

  resources :transactions do
    collection do
      get :get_group_balance
      get :autocomplete_category_tags
    end
  end

  resources :users do
    member do
      get :dashboard
    end
  end
end
