if defined?(Localeapp)
  require 'localeapp/rails'

  Localeapp.configure do |config|
    if defined?(Setting) && Setting.localeapp!.api_key.present?
      config.api_key = Setting.localeapp.api_key
      config.sending_environments   = Setting.localeapp.sending_environments.to_a
      config.polling_environments   = Setting.localeapp.polling_environments.to_a
      config.reloading_environments = Setting.localeapp.reloading_environments.to_a
    else
      config.api_key = ENV['LOCALEAPP_TOKEN']
    end
  end
end
