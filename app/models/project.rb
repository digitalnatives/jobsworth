# encoding: UTF-8
# A logical grouping of milestones and tasks, belonging to a Customer / Client

class Project < AbstractProject

  def dup_and_get_template(template_id = nil)
    begin
      template = ProjectTemplate.find(template_id)
    rescue ActiveRecord::RecordNotFound => e
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      return
    end

    template.milestones.each do |template_milestone|
      copied_milestone = template_milestone.dup
      if start_at.present? && copied_milestone.due_at.present?
        copied_milestone.due_at += (start_at - template.start_at).days
      end
      self.milestones << copied_milestone
    end
    template.score_rules.each do |template_score_rule|
      self.score_rules << template_score_rule.dup
    end
    template.project_permissions.each do |template_project_permission|
      self.project_permissions << template_project_permission.dup
    end

    template.task_templates.each do |template_task|
      copied_task = template_task.dup
      copied_task = copied_task.becomes(TaskRecord)
      template_task.todos.each do |template_todos|
        copied_task.todos << template_todos
      end
      template_task.customers.each do |template_owners|
        copied_task.owners << template_owners
      end
      template_task.users.each do |template_user|
        copied_task.users << template_user
      end
      template_task.watchers.each do |template_watcher|
        copied_task.watchers << template_watcher
      end
      template_task.task_property_values.each do |template_task_property|
        copied_task.task_property_values << template_task_property.dup
      end
      self.tasks << copied_task
    end

    template
  end

end

# == Schema Information
#
# Table name: projects
#
#  id               :integer(4)      not null, primary key
#  name             :string(200)     default(""), not null
#  company_id       :integer(4)      default(0), not null
#  customer_id      :integer(4)      default(0), not null
#  created_at       :datetime
#  updated_at       :datetime
#  completed_at     :datetime
#  critical_count   :integer(4)      default(0)
#  normal_count     :integer(4)      default(0)
#  low_count        :integer(4)      default(0)
#  description      :text
#  open_tasks       :integer(4)
#  total_tasks      :integer(4)
#  total_milestones :integer(4)
#  open_milestones  :integer(4)
#  default_estimate :decimal(5, 2)   default(1.0)
#
# Indexes
#
#  projects_company_id_index   (company_id)
#  projects_customer_id_index  (customer_id)
#

