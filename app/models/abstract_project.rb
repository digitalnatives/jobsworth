class AbstractProject < ActiveRecord::Base
  self.table_name = "projects"

  # Creates a score_rules association and updates the score
  # of all the task when adding a new score rule
  include Scorable

  belongs_to    :company
  belongs_to    :customer

  has_many      :users, :through => :project_permissions, :foreign_key => 'project_id'
  has_many      :project_permissions, :dependent => :destroy, :foreign_key => 'project_id'
  has_many      :tasks, :class_name => "TaskRecord", :foreign_key => 'project_id'
  has_many      :sheets, :dependent => :destroy, :foreign_key => 'project_id'
  has_many      :work_logs, :dependent => :destroy, :foreign_key => 'project_id'
  has_many      :project_files, :dependent => :destroy, :foreign_key => 'project_id'
  has_many      :milestones, :dependent => :destroy, :order => "due_at asc, lower(name) asc", :foreign_key => 'project_id'
end
