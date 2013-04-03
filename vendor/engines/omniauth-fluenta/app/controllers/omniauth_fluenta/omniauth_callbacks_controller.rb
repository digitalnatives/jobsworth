module OmniauthFluenta
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    def passthru
      render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
      # Or alternatively,
      # raise ActionController::RoutingError.new('Not Found')
    end

    def fluenta
      render json: request.env['omniauth.auth'].to_json
    end

  end
end
