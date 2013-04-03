require 'omniauth/strategies/oauth2'
# {"user":{
#   "id":13,
#   "language":"hu",
#   "username":"testcadmin",
#   "full_name":"Cegesadmin Teszt",
#   "company":{
#     "email":"",
#     "id":2,
#     "name":"Electool"}}}

module OmniAuth
  module Strategies
    class Fluenta < OmniAuth::Strategies::OAuth2

      option :name, :fluenta
      option :client_options, {:authorize_url => '/oauth/authorize'}

      uid { raw_info['id'] }

      info {{
        email:      raw_info['email'],
        name:       raw_info['full_name'],
        first_name: raw_info['first_name'],
        last_name:  raw_info['first_name'],
        nickname:   raw_info['username'],
        language:   raw_info['language'],
        company: {
          uid:       raw_company_info['id'],
          name:      raw_company_info['name'],
          email:     raw_company_info['email'],
          subdomain: raw_company_info['slug']
        }
      }}

      def raw_info
        @raw_info ||= access_token.get('/api/user.json').parsed
      end

      def raw_company_info
        @raw_company_info ||= raw_info['company'] || {}
      end

    end
  end
end

