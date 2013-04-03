module OmniauthFluenta
  class Engine < ::Rails::Engine
    isolate_namespace OmniauthFluenta

    initializer 'register.fluenta' do |app|
    end
  end
end
