Jobsworth::Application.routes.draw do
  scope ActionController::Base.config.relative_url_root || "/" do

  devise_prefix = ActionController::Base.config.relative_url_root.to_s.sub('/', '')

  devise_scope :user do
    match "users/auth/:provider",          to: 'omniauth_fluenta/omniauth_callbacks#passthru', as: :user_omniauth_authorize, constraints: {provider: /fluenta/ }
    match "users/auth/:provider/callback", to: 'omniauth_fluenta/omniauth_callbacks#fluenta',  as: :user_omniauth_callback, constraints: {provider: /fluenta/ }
  end
  devise_for :users,
             :path_prefix => [devise_prefix, 'auth'].reject(&:blank?).join('/'),
             :controllers => { :sessions  => "auth/sessions",
                               :passwords => "auth/passwords" }

  resources :snippets

  resources :service_level_agreements, :only => [:create, :destroy, :update]

  resources :services, :except => [:show] do
    collection do
      get 'auto_complete_for_service_name'
    end
  end

  resources :users, :except => [:show] do
    member do
      match :access, :via => [:get, :put]
      get :emails
      get :projects
      get :tasks
      get :filters
      match :workplan, :via => [:get, :put]
      get :project
    end
    collection do
      get :auto_complete_for_project_name
      get :auto_complete_for_user_name
    end
  end

  get 'activities/index', as: 'activities'
  root :to => 'activities#index'

  get '/unified_search' => "customers#search"
  resources :customers do
    collection do
      get 'auto_complete_for_customer_name'
    end
  end

  resources :news_items,  :except => [:show]
  resources :projects do
    get 'list_completed', :on => :collection

    member do
      get :ajax_add_permission
      get 'clone'
      post :complete
      post :revert
    end
  end

  # task routes
  get 'tasks/:id' => "tasks#edit", :constraints => {:id => /\d+/}
  get "tasks/view/:id" => "tasks#edit", :as => :task_view
  get "tasks/next_tasks/:count" => "tasks#next_tasks", :defaults => { :count => 5 }, as: :next_tasks
  resources :tasks, :except => [:show] do
    collection do
      get  'billable'
      get  'calendar'
      get  'gantt'
      get  'get_default_customers'
      get  'get_default_watchers'
      get  'get_default_watchers_for_customer'
      get  'planning'
      get  'dependency'
      get  'auto_complete_for_resource_name'
      get  'resource'
      post 'change_task_weight'
      get  'refresh_service_options'
      get  'get_customer'
      get  'get_watcher'
    end
    member do
      get 'clone'
      get 'score'
      get 'users_to_notify_popup'
    end
  end

  resources :email_addresses, :except => [:show] do
    member do
      put :default
    end
  end

  resources :resources do
    collection do
      get :attributes
      get :auto_complete_for_resource_parent
    end
    get :show_password, :on => :member
  end

  resources :resource_types do
    collection do
      get :attribute
    end
  end

  resources :organizational_units

  resources :task_filters do
    get :toggle_status, :on => :member
    match :select, :on => :member
    collection do
      get :search
      get :update_current_filter
      get :set_single_task_filter
    end
  end

  resources :todos do
    match :toggle_done, :on => :member
    post :reorder, on: :collection
    get  :toggle_done_for_uncreated_task, on: :collection
  end

  resources :work_logs do
    match 'update_work_log', on: :member
  end

  resources :tags do
    collection do
      get :auto_complete_for_tags
    end
  end

  resources :work do
    collection do
      get :start
      get :stop
      get :cancel
      get :pause
      get :refresh
    end
  end

  resources :project_files, only: [ :show ] do
    member do
      get :thumbnail
      get :download
      get :destroy_file
    end
  end

  resources :properties do
    collection do
      get :remove_property_value_dialog
      post :remove_property_value
      post :order
    end
  end

  resources :scm_projects
  resources :triggers

  resource :timeline, only: :show

  resources :billings, only: :index do
    get :get_csv, on: :collection
  end

  resources :projects, :customers, :property_values do
    get 'list_completed', on: :collection
    resources :score_rules
  end

  resources :project_templates do
    resources :score_rules
  end

  resources :milestones do
    resources :score_rules

    collection do
      get :get_milestones
    end

    member do
      post :revert
      post :complete
    end
  end

  resources :task_templates do
    collection do
      get :auto_complete_for_dependency_targets
      get :dependency
    end
  end

  resources :companies do
    resources :score_rules
    collection do
      get :score_rules
      get :custom_scripts
      get :properties
    end
    member do
      get  :show_logo
    end
  end

  resources :emails, only: [:create]

  resources :widgets do
    post :save_order,    on: :collection
    get :toggle_display, on: :member
  end

  resources :custom_attributes, only: [:index, :edit, :update] do
    collection do
      get 'fields'
      get 'choice' # it should be on member, look at action
      get 'edit'
    end
  end

  ActiveAdmin.routes(self)

  match 'api/scm/:provider/:secret_key' => 'scm_changesets#create'
  match ':controller/list' => ':controller#index'

  match ":controller(/:action(/:id(.:format)))"

  end
end
