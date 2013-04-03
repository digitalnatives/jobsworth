OmniAuth.config.logger = Rails.logger

module OmniAuth
  module Strategies
    autoload :Fluenta, 'fluenta_strategy'
  end
end

ENV['FLUENTA_KEY']    = '2884cee22cdc089ecbe61518195fa59dd15b4917003da7adf7678acf1c647932'
ENV['FLUENTA_SECRET'] = '44b7fe4dab69abb82caac717d392ea4915e16f88025f929f99f25f2ff0c81809'
ENV['FLUENTA_SITE']   = 'http://localhost:3001'

Devise.setup do |config|
  config.omniauth :fluenta, ENV['FLUENTA_KEY'], ENV['FLUENTA_SECRET'], client_options: {site: ENV['FLUENTA_SITE']}
end

