class AddStiToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :type, :string
    AbstractProject.update_all(type: "Project")
  end
end
