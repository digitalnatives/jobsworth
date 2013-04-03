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
