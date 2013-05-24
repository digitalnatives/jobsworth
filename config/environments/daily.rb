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
end
