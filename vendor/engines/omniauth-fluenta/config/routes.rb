OmniauthFluenta::Engine.routes.draw do

  prefix = ActionController::Base.config.relative_url_root.to_s.sub('/', '')
  devise_scope :user do
    get "#{prefix}/users/auth/fluenta",          to: 'omniauth_callbacks#passthru', as: :users_auth_fluenta
    get "#{prefix}/users/auth/fluenta/callback", to: 'omniauth_callbacks#fluenta',  as: :users_auth_fluenta_callback
  end

end
