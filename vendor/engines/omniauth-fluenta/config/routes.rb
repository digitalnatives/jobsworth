OmniauthFluenta::Engine.routes.draw do

  devise_scope :user do
    get '/users/auth/fluenta', to: 'omniauth_callbacks#passthru'
    get '/users/auth/fluenta/callback', to: 'omniauth_callbacks#fluenta'
  end

end
