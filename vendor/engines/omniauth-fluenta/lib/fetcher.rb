module OmniauthFluenta
  class Fetcher

    class InsufficientCompanyData < StandardError; end
    class InsufficientUserData < StandardError; end
    class CompanyFetchError < StandardError; end
    class UserFetchError < StandardError; end

    REQUIRED_USER_DATA    = ['fluenta_id', 'username', 'name', 'email'] # language?
    REQUIRED_COMPANY_DATA = ['fluenta_id', 'name', 'subdomain'] # email?

    LANGUAGES = { 'hu' => 'hu_HU',
                  'en' => 'en_US',
                  'he' => 'he_IL' }

    def self.user(*args)
      new(*args)
    end

    def initialize(auth_hash)

      user_info    =  { fluenta_id:     auth_hash['uid'].to_i,
                        name:           auth_hash['info']['name'],
                        email:          auth_hash['info']['email'],
                        locale:         LANGIAGES[auth_hash['info']['language']],
                        username:       '???'
                      } rescue {}

      # TODO: email = contact_email or needs handling?
      company_info =  { fluenta_id:     auth_hash['info']['company']['uid'].to_i,
                        name:           auth_hash['info']['company']['name'],
                        contact_email:  auth_hash['info']['company']['email'],
                        subdomain:      auth_hash['info']['company']['subdomain'],
                      } rescue {}

      raise InsufficientCompanyData  if REQUIRED_COMPANY_DATA.any?{ |key| company_info[key].blank? }
      raise InsufficientUserData     if REQUIRED_USER_DATA.any?{ |key| user_info[key].blank? }

      company = get_company! company_info
      user    = get_user! user_info.merge(company: company)
    end

    private

    ['Company', 'User'].each do |klass|
      define_method "get_#{klass.underscore}!" do |params|
        begin
          klass.constantize.find_by_fluenta_id(params['fluenta_id']).try(:update_attributes!, params) ||
          klass.constantize.create!(params)
        rescue StandardError
          raise "#{klass}FetchError".constantize
        end
      end
    end

  end
end