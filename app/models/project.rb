# encoding: UTF-8
# A logical grouping of milestones and tasks, belonging to a Customer / Client

class Project < AbstractProject

  def copy_template(template)
    @template = template

    copy_and_ajust_milestones
    copy_score_rules
    copy_project_permissions
    TaskTemplatesCloner.clone from: template, to: self

  rescue ActiveRecord::RecordNotFound => e
    logger.error "Project.dup_and_get_template(#{template})"
    logger.error e.message
    logger.error e.backtrace.join("\n")
  end

private
  def template; @template; end

  def copy_and_ajust_milestones
    template.milestones.each do |template_milestone|
      copied_milestone = template_milestone.dup
      if start_at.present? && copied_milestone.due_at.present?
        copied_milestone.due_at += (start_at - template.start_at).days
      end
      self.milestones << copied_milestone
    end
  end

  def copy_score_rules
    template.score_rules.each do |template_score_rule|
      self.score_rules << template_score_rule.dup
    end
  end

  def copy_project_permissions
    template.project_permissions.each do |template_project_permission|
      self.project_permissions << template_project_permission.dup
    end
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

