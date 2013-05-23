require 'migration_helpers/status_numbers_to_open_closed'

class MigrateStatusesToRelation < ActiveRecord::Migration
  def up
    StatusNumbersToOpenClosed.new.migrate
  end

  def down
    puts 'Irreversible migration!'
  end
end
