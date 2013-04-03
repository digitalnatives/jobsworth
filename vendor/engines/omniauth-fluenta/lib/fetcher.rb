module OmniauthFluenta
  class Fetcher

    class InsufficientCompanyData < StandardError; end
    class InsufficientUserData < StandardError; end
    class CompanyFetchError < StandardError; end
    class UserFetchError < StandardError; end

    REQUIRED_USER_DATA    = [:fluenta_id, :username, :name, :email]
    REQUIRED_COMPANY_DATA = [:fluenta_id, :name, :subdomain]

    LANGUAGES = { 'hu' => 'hu_HU',
                  'en' => 'en_US',
                  'he' => 'he_IL' }

    def self.user(*args)
      new(*args).user
    end

    def initialize(auth_hash)
      @user_info    = { fluenta_id:     auth_hash['uid'].to_i,
                        name:           auth_hash['info']['name'],
                        email:          auth_hash['info']['email'],
                        locale:         LANGUAGES[auth_hash['info']['language']],
                        username:       auth_hash['info']['nickname']
                      } rescue {}

      @company_info = { fluenta_id:     auth_hash['info']['company']['uid'].to_i,
                        name:           auth_hash['info']['company']['name'],
                        contact_email:  auth_hash['info']['company']['email'],
                        subdomain:      auth_hash['info']['company']['subdomain'],
                      } rescue {}

      raise InsufficientCompanyData  if REQUIRED_COMPANY_DATA.any?{ |key| @company_info[key].blank? }
      raise InsufficientUserData     if REQUIRED_USER_DATA.any?{ |key| @user_info[key].blank? }
    end

    def user
      get_user! @user_info.merge(:company => get_company!(@company_info))
    end

    private

    ['Company', 'User'].each do |klass|
      define_method "get_#{klass.underscore}!" do |params|
        begin
          record = klass.constantize.find_by_fluenta_id(params[:fluenta_id])
          if record.present?
            record.update_attributes! params
          else
            record = klass.constantize.new params
            record.save!
          end
          record
        rescue StandardError
          raise "OmniauthFluenta::Fetcher::#{klass}FetchError".constantize
        end
      end
    end

  end
end