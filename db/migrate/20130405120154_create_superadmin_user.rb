class CreateSuperadminUser < ActiveRecord::Migration
  def up
    c = Company.create name: 'Administration',
                       subdomain: 'administration'
        User.create    company: c,
                       username: 'admin',
                       name: 'Administrator',
                       email: 'superadmin@getjobsworth.org',
                       password: '123456',
                       password_confirmation: '123456',
                       superadmin: true
  end

  def down
    Company.destroy_all subdomain: 'administration'
    User.destroy_all super_admin: true
  end

end
