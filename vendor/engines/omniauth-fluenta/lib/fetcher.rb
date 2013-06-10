module OmniauthFluenta
  class Fetcher

    class InsufficientCompanyData < StandardError; end
    class InsufficientUserData < StandardError; end
    class CompanyFetchError < StandardError; end
    class UserFetchError < StandardError; end

    REQUIRED_USER_DATA    = [:fluenta_id, :username, :name, :email]
    REQUIRED_COMPANY_DATA = [:fluenta_id, :name, :subdomain]

    def self.user(*args)
      new(*args).user
    end

    def initialize(auth_hash)
      @user_info    = user_info auth_hash
      @company_info = company_info auth_hash

      raise InsufficientCompanyData if REQUIRED_COMPANY_DATA.any?{ |key| @company_info[key].blank? }
      raise InsufficientUserData    if REQUIRED_USER_DATA.any?{ |key| @user_info[key].blank? }
    end

    def user
      get_user! @user_info.merge(:company => get_company!(@company_info))
    end

  private
    def user_info(hash)
      {
        fluenta_id:hash['uid'].to_i,
        name:      hash['info']['name'],
        email:     hash['info']['email'],
        locale:    hash['info']['language'],
        username:  hash['info']['nickname']
      }
    rescue
      {}
    end

    def company_info(hash)
      {
        fluenta_id:      hash['info']['company']['uid'].to_i,
        name:            hash['info']['company']['name'],
        contact_email:   hash['info']['company']['email'],
        subdomain:       hash['info']['company']['subdomain'],
        # Set default values
        show_wiki:       false,
        use_resources:   false,
        use_score_rules: false,
        use_billing:     false
      }
    rescue
      {}
    end

    def create_customer(company)
      Customer.create!({name: company.name, company: company})
    end

    ['Company', 'User'].each do |klass|
      define_method "get_#{klass.underscore}!" do |params|
        begin
          record = klass.constantize.find_by_fluenta_id(params[:fluenta_id])
          if record.present?
            record.update_attributes! params
          else
            record = klass.constantize.new params
            record.no_default_properties = true if klass == 'Company'
            record.save!

            create_customer record if klass == 'Company'
          end
          record
        rescue StandardError
          raise "OmniauthFluenta::Fetcher::#{klass}FetchError".constantize
        end
      end
    end

  end
end
