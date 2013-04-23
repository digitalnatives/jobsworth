module OmniauthFluenta
  class ApplicationController < ActionController::Base
    def after_sign_in_path_for(resource_or_scope)
      main_app.root_url
    end
  end
end
