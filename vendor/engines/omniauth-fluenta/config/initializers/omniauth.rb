OmniAuth.config.logger = Rails.logger

module OmniAuth
  module Strategies
    autoload :Fluenta, 'fluenta_strategy'
  end
end

Devise.setup do |config|
  rconfig = Rails.configuration.jobsworth.omniauth
  app_id  = rconfig.fluenta.app_id
  secret  = rconfig.fluenta.secret
  site    = rconfig.fluenta.site

  config.omniauth :fluenta, app_id, secret, client_options: {site: site}
end

