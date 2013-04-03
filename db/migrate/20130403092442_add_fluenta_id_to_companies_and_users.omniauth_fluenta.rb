# This migration comes from omniauth_fluenta (originally 20130403090801)
class AddFluentaIdToCompaniesAndUsers < ActiveRecord::Migration
  def self.up
    add_column :users,        :fluenta_id, :integer
    add_column :companies,    :fluenta_id, :integer
  end

  def self.down
    remove_column :users,     :fluenta_id
    remove_column :companies, :fluenta_id
  end
end
