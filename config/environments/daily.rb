ENV['RAILS_RELATIVE_URL_ROOT'] = '/project-management'

Jobsworth::Application.configure do
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = true
  config.assets.digest = true
  config.assets.compress = true
  config.assets.js_compressor  = Closure::Compiler.new

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w(excanvas.js)

  # Enable threaded mode
  config.threadsafe! if defined?(JRUBY_VERSION)

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
  config.action_controller.relative_url_root = ENV['RAILS_RELATIVE_URL_ROOT']

  # CAS settings
  # config.x.cas.base_url = "http://cas.electool-daily.staging.hu/"
  config.x.cas.base_url = 'https://auth-daily.fluenta.eu'
  config.x.profile_manager.base_url = 'https://admin-daily.fluenta.eu'
  config.x.cas.pepper   = 'fecc64637916941d08ad4795a767bc5441c74095deabb25605598c352a6c15138cb672a9b7d00b601428b64fc5b9ae65aa8fca7ab85bffc216efa9993c7948f6'
  config.x.cas.stretches = 10
  config.x.messaging.application_name = 'fluenta-profile-manager-daily'
  config.x.messaging.raise_error_on_publish_failure = false
end
