module OmniauthFluenta

  require 'fetcher'

  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    def passthru
      render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
      # Or alternatively,
      # raise ActionController::RoutingError.new('Not Found')
    end

    def fluenta
      resource = OmniauthFluenta::Fetcher.user(request.env['omniauth.auth'].to_hash)
      sign_in_and_redirect(resource_name, resource)
    end

  end
end
