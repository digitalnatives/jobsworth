require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Fluenta < OmniAuth::Strategies::OAuth2

      option :name, :fluenta
      option :client_options, {:authorize_url => '/oauth/authorize'}

      uid { raw_user_info['id'] }

      info {{
        email:      raw_user_info['email'],
        name:       raw_user_info['full_name'],
        first_name: raw_user_info['first_name'],
        last_name:  raw_user_info['last_name'],
        nickname:   raw_user_info['username'],
        language:   raw_user_info['language'],
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

      def raw_user_info
        @raw_user_info ||= raw_info['user'] || {}
      end

      def raw_company_info
        @raw_company_info ||= raw_user_info['company'] || {}
      end

    end
  end
end

