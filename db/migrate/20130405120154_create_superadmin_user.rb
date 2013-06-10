require 'migration_helpers/create_superadmin'

class CreateSuperadminUser < ActiveRecord::Migration
  def up
    CreateSuperadmin.new.up
  rescue
    puts 'Error while running "CreateSuperadmin.new.up"'
  end

  def down
    CreateSuperadmin.new.down
  rescue
    puts 'Error while running "CreateSuperadmin.new.down"'
  end

end
