OmniAuth.config.logger = Rails.logger

module OmniAuth
  module Strategies
    autoload :Fluenta, 'fluenta_strategy'
  end
end

Devise.setup do |config|
  if rconfig = Rails.configuration.jobsworth.omniauth
    app_id  = rconfig.fluenta.app_id
    secret  = rconfig.fluenta.secret
    site    = rconfig.fluenta.site

    # TODO This is a HACK to prevent devise to override the custom omniauth
    # paths
    config.omniauth :fluenta, app_id, secret, client_options: {site: site},
                    request_path:  "#{ENV['RAILS_RELATIVE_URL_ROOT']}/users/auth/fluenta",
                    callback_path: "#{ENV['RAILS_RELATIVE_URL_ROOT']}/users/auth/fluenta/callback"
  end
end

