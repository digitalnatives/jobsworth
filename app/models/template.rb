# encoding: UTF-8
# This model is to task templates
# use the same table as Task  model.
class Template < AbstractTask

  self.default_scopes = []

  def clone_todos
    todos.map { |todo| todo.dup.detach_from_task }
  end

  def duplicate(ajustment_days = 0)
    copied_task = self.dup.becomes(TaskRecord)

    copied_task.owners   = self.owners
    copied_task.users    = self.users
    copied_task.watchers = self.watchers
    copied_task.todos    = self.clone_todos
    copied_task.due_at   += ajustment_days if copied_task.due_at

    self.task_property_values.each do |template_task_property|
      copied_task.task_property_values << template_task_property.dup
    end

    copied_task
  end

end









# == Schema Information
#
# Table name: tasks
#
#  id                 :integer(4)      not null, primary key
#  name               :string(200)     default(""), not null
#  project_id         :integer(4)      default(0), not null
#  position           :integer(4)      default(0), not null
#  created_at         :datetime        not null
#  due_at             :datetime
#  updated_at         :datetime        not null
#  completed_at       :datetime
#  duration           :integer(4)      default(1)
#  hidden             :integer(4)      default(0)
#  milestone_id       :integer(4)
#  description        :text
#  company_id         :integer(4)
#  priority           :integer(4)      default(0)
#  updated_by_id      :integer(4)
#  severity_id        :integer(4)      default(0)
#  type_id            :integer(4)      default(0)
#  task_num           :integer(4)      default(0)
#  status             :integer(4)      default(0)
#  creator_id         :integer(4)
#  hide_until         :datetime
#  worked_minutes     :integer(4)      default(0)
#  type               :string(255)     default("Task")
#  weight             :integer(4)      default(0)
#  weight_adjustment  :integer(4)      default(0)
#  wait_for_customer  :boolean(1)      default(FALSE)
#
# Indexes
#
#  index_tasks_on_type_and_task_num_and_company_id  (type,task_num,company_id) UNIQUE
#  tasks_company_id_index                           (company_id)
#  tasks_due_at_idx                                 (due_at)
#  index_tasks_on_milestone_id                      (milestone_id)
#  tasks_project_completed_index                    (project_id,completed_at)
#  tasks_project_id_index                           (project_id,milestone_id)
#

