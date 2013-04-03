OmniAuth.config.logger = Rails.logger

module OmniAuth
  module Strategies
    autoload :Fluenta, 'fluenta_strategy'
  end
end

Devise.setup do |config|
  config.omniauth :fluenta, ENV['FLUENTA_KEY'], ENV['FLUENTA_SECRET'], client_options: {site: ENV['FLUENTA_SITE']}
end

