class CreateSuperadminUser < ActiveRecord::Migration
  def up
    c = Company.create  fluenta_id: 0,
                        name: 'Administration',
                        subdomain: 'administration'
        User.create     company: c,
                        fluenta_id: 0,
                        username: 'admin',
                        name: 'Administrator',
                        email: 'superadmin@electool.com',
                        password: '123456',
                        password_confirmation: '123456',
                        superadmin: true
  end

  def down
    Company.find_all_by_fluenta_id(0).each &:destroy
    User.find_all_by_fluenta_id(0).each &:destroy
  end

end
