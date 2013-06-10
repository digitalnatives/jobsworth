class AddBooleanFieldsToStatuses < ActiveRecord::Migration
  def change
    add_column :statuses, :open,         :boolean, default: false
    add_column :statuses, :closed,       :boolean, default: false
    add_column :statuses, :will_not_fix, :boolean, default: false
    add_column :statuses, :not_valid,    :boolean, default: false
    add_column :statuses, :duplicate,    :boolean, default: false

    add_column :statuses, :resolved,    :boolean, default: false
  end
end
