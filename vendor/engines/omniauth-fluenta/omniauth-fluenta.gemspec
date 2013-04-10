$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'omniauth-fluenta/version'

Gem::Specification.new do |s|
  s.name        = 'omniauth-fluenta'
  s.version     = OmniauthFluenta::VERSION
  s.authors     = ['Gergo Sulymosi']
  s.email       = ['gergo.sulymosi@digitalnatives.hu']
  s.summary     = 'Authorization and authentication logic, to handle fluenta users'
  s.description = s.summary

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '~> 3.2.10'
  s.add_dependency 'omniauth'
  s.add_dependency 'omniauth-oauth2'
end
