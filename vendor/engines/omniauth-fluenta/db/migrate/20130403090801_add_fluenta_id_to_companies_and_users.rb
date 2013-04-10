class AddFluentaIdToCompaniesAndUsers < ActiveRecord::Migration
  def self.up
    add_column :users,        :fluenta_id, :integer
    add_column :companies,    :fluenta_id, :integer

    add_index :users,         :fluenta_id, :unique => true
    add_index :companies,     :fluenta_id, :unique => true

  end

  def self.down
    remove_index :users,      :fluenta_id
    remove_index :companies,  :fluenta_id

    remove_column :users,     :fluenta_id
    remove_column :companies, :fluenta_id
  end
end
