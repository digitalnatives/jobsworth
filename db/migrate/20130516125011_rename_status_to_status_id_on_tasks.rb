class RenameStatusToStatusIdOnTasks < ActiveRecord::Migration
  def up
    rename_column :tasks, :status, :status_id
    change_column :tasks, :status_id, :integer, default: nil
  end

  def down
    change_column :tasks, :status_id, :integer, default: 0
    rename_column :tasks, :status_id, :status
  end
end
