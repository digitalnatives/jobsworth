module OmniauthFluenta

  require 'fetcher'

  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    def passthru
      render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
      # Or alternatively,
      # raise ActionController::RoutingError.new('Not Found')
    end

    def fluenta
      begin
        sign_in_and_redirect OmniauthFluenta::Fetcher.user(request.env['omniauth.auth'].to_hash), :event => :authentication
        set_flash_message(:notice, :success, :kind => "Fluenta") if is_navigational_format?
      rescue StandardError => e
        logger.debug "\nException occured while trying to sign in via fluenta :\n\t#{e.inspect}\n#{e.backtrace}\n"
        redirect_to request.env['omniauth.origin'], :alert => _("Internal error occured while trying to sign in through Fluenta...")
      end
    end

  end
end
