Jobsworth::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  #Change this to your real configuration
  config.action_mailer.smtp_settings = {
    :address        => 'smtp.gmail.com',
    :port           => 587,
    :domain         => 'gmail.com',
    :authentication => :login,
    :user_name      => 'username@host.com', #ex. intale.a@gmail.com
    :password       => 'password'
  }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  config.after_initialize do
    # Bullet.enable = true
    # Bullet.alert = false
    # Bullet.bullet_logger= true
    # Bullet.console = false
    # Bullet.rails_logger = false
    # Bullet.growl = false
    # Bullet.disable_browser_cache= false
  end

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # ENV['RAILS_RELATIVE_URL_ROOT'] = '/project-management'
  # config.action_controller.relative_url_root = ENV['RAILS_RELATIVE_URL_ROOT']

  # CAS settings
  config.x.profile_manager.base_url = 'http://fluenta.profilemanager.dev'
  config.x.cas.base_url = 'http://cas.electool.dev/'
  config.x.cas.pepper   = 'fecc64637916941d08ad4795a767bc5441c74095deabb25605598c352a6c15138cb672a9b7d00b601428b64fc5b9ae65aa8fca7ab85bffc216efa9993c7948f6'
  config.x.cas.stretches = 10
  config.x.messaging.application_name = 'procurementtool-development'
  config.x.messaging.raise_error_on_publish_failure = false
end
