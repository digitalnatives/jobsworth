class AddStiToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :type, :string
    AbstractProject.update_all(type: "Project")
    add_column :projects, :start_at, :date
  end
end
